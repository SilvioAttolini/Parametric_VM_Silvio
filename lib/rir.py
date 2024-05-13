from icecream import ic
import numpy as np
import scipy

from lib.sim_microphone import sim_microphone

"""
" RIR
"   args: params, room, source, 
"       array_or_vms = contains the positions of the mic in arrays, or of the vms
"       [iSrc, aa, mm] when array
"       [iSrc, vm] when vms
"       varargin = boolean that de/activates diffuse_time
"   returns: IR, RTF = rir_time, rirSTFT
"""


def rir(params, room, source, array_or_vms, indices, varargin):

    if len(indices) == 3:
        i_src, aa, mm = indices[0], indices[1], indices[2]
        curr_mic_pos = array_or_vms['positions'][aa][mm]  # array
    else:
        i_src, vm = indices[0], indices[1]
        curr_mic_pos = array_or_vms['positions'][vm]  # cptPts (vms)

    c = params['c']
    source_pos = source['position'][i_src]
    L = room['dim']
    beta = np.array([room['T60']]) if varargin else np.array([0])
    m_type = source['type'][i_src]
    n_order = room['reflectionOrder'] if varargin else 0
    orientation = source['orientation'][i_src]
    diffuse_time = room['diffuseTime'] if varargin else None

    if len(beta) == 1:
        if beta[0] != 0:
            V = L[0] * L[1] * L[2]
            S = 2 * (L[0] * L[1]) + 2 * (L[0] * L[2]) + 2 * (L[1] * L[2])
            alfa = 24 * V * np.log(10.0) / (c * S * beta[0])  # log is nat_log
            if alfa > 1:
                raise ValueError('Error: The reflection coefficients cannot be calculated using the current '
                                 'room parameters, i.e. room size and reverberation time Please specify the '
                                 'reflection coefficients or change the room parameters.')
            else:
                beta = np.zeros(6)
                for i in range(6):
                    beta[i] = np.sqrt(1 - alfa)
        else:
            beta = np.zeros(6)
    else:
        beta = beta

    r = np.zeros(3)
    res = []
    Rp_plus_Rm = np.zeros(3)
    Rm = np.zeros(3)
    for mx in range(-n_order, n_order + 1):
        Rm[0] = 2 * mx * L[0]

        for my in range(-n_order, n_order + 1):
            Rm[1] = 2 * my * L[1]

            for mz in range(-n_order, n_order + 1):
                Rm[2] = 2 * mz * L[2]

                for q in [0, 1]:
                    Rp_plus_Rm[0] = (1 - 2 * q) * curr_mic_pos[0] - r[0] + Rm[0]
                    refl_1 = beta[0]**np.abs(mx - q) * beta[1]**np.abs(mx)

                    for jj in [0, 1]:
                        Rp_plus_Rm[1] = (1 - 2 * jj) * curr_mic_pos[1] - r[1] + Rm[1]
                        refl_2 = beta[2]**np.abs(my - jj) * beta[3]**np.abs(my)

                        for k in [0, 1]:
                            Rp_plus_Rm[2] = (1 - 2 * k) * curr_mic_pos[2] - r[2] + Rm[2]
                            refl_3 = beta[4]**np.abs(mz - k) * beta[5]**np.abs(mz)

                            if ((np.abs(2 * mx - q) + np.abs(2 * my - jj) + np.abs(2 * mz - k) <= n_order) or
                                    (n_order == -1)):
                                res.append(np.concatenate((Rp_plus_Rm, np.array([refl_1*refl_2*refl_3]))))

    res = np.array(res)

    k = 2 * np.pi * params['f_ax'] / c

    if diffuse_time:  # check?
        early_distance = diffuse_time * c
        direct_distance = scipy.spatial.distance.pdist(res[:3, :].T, source_pos.T)
        [min_val, direct_idx] = np.min(direct_distance, axis=1)
        late_distance = min_val + early_distance
        late_idx = direct_distance > late_distance
        late_idx[direct_idx] = 1
        res = res[:, late_idx]

    gain = np.zeros((1, np.shape(res)[0]))
    for idx in range(np.shape(res)[0]):
        x = res[idx, 0] - source_pos[0]
        y = res[idx, 1] - source_pos[1]
        z = res[idx, 2] - source_pos[2]

        a1 = sim_microphone(x, y, z, orientation, m_type)
        resh1 = np.reshape(res[idx, :3], (1, 3))
        resh2 = np.reshape(source_pos, (1, 3))
        a2 = scipy.spatial.distance.cdist(resh1, resh2)[0][0]
        gain[0, idx] = res[idx, 3]*a1 / (4*np.pi*a2)

    dist = scipy.spatial.distance.cdist(res[:, :3], np.reshape(source_pos, (1, 3)))
    aux = np.exp(-1j * k * dist)
    aux = aux * np.repeat(gain.T, len(k), axis=1)
    RTF = np.sum(aux, axis=0)

    qq = RTF[::-1]
    rev_rtf = np.reshape(qq, (1, np.shape(qq)[0]))
    RTF = np.reshape(RTF, (1, np.shape(RTF)[0]))

    IR = np.real(scipy.fftpack.ifft(np.concatenate((RTF, np.conj(rev_rtf)), axis=1), axis=1))  # since Re>>>Im

    return IR, RTF

    # ww = qq[1:-1]  # exclude extremes for computational correction
    # rev_rtf = np.reshape(ww, (1, np.shape(ww)[0]))
