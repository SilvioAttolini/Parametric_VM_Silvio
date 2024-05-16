import numpy as np
from icecream import ic
from lib.doa_estimator import doa_estimator
from localization.wrap_to_2pi import wrap_to_2pi
from localization.remove_external_doa import remove_external_doa

"""
"
"""

tab = "    "


def doas_with_weights(params, sources, array, dereverb_stft, theta_ax, sd_filter):
    print(tab+tab+tab+"> Calculating doas with weights...")

    # time axis
    time_frame_step = 1
    time_axis = np.arange(0, len(params['t_ax']), time_frame_step)

    all_doa = np.zeros((sources['N'], array['N'], len(time_axis)))
    all_weight = np.zeros((sources['N'], array['N'], len(time_axis)))

    for aa in range(array['N']):
        ic("Array: ", aa)
        for idx, tt in enumerate(time_axis):
            print(".") if idx % 10 != 0 else print("\n")

            stop_frame = np.min([time_frame_step, np.shape(dereverb_stft)[3]])  # 3 means tLen
            mic_signal = dereverb_stft[aa, :, :, tt+stop_frame]
            # mic_signal = np.squeeze(np.mean(mic_signal))  # here a [micN, fLen]. matlab: [fLen, 1, micN]
            mic_signal = np.mean(mic_signal)  # here a [micN, fLen]. matlab: [fLen, 1, micN]

            doa_weight, doa = doa_estimator(mic_signal, sd_filter, theta_ax, [])

            # Prune external DOA
            idx_prev = (aa - 1) % array.N + 1
            idx_next = (aa + 1) % array.N + 1
            tmp_prev = array['centers'][idx_prev] - array['centers'][aa]
            tmp_succ = array['centers'][idx_next] - array['centers'][aa]
            ang_prev = np.arctan2(tmp_prev[1], tmp_prev[0])
            ang_succ = np.arctan2(tmp_succ[1], tmp_succ[0])

            doa_new, idxDoa = remove_external_doa(doa, ang_succ, ang_prev)
            doa_new = doa_new[:min(len(doa_new), sources['N'])]

            doa_idx = np.searchsorted(wrap_to_2pi(doa), doa_new, side='left')
            doa_val = doa_weight[doa_idx]

            if not doa_new.any():  # NO DOA FOUND
                print('-')
                doa_new = np.full(sources['N'], np.nan)
                doa_val = doa_new

            all_doa[:, aa, idx] = doa_new
            all_weight[:, aa, idx] = doa_val

    return all_doa, all_weight
