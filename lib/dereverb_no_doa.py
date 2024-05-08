import numpy as np
from icecream import ic
from lib.estimate_cdr_no_doa import estimate_cdr_no_doa
from lib.estimate_psd import estimate_psd
from lib.estimate_cpsd import estimate_cpsd
from scipy.spatial.distance import cdist
from lib.estimate_cdr_no_doa import estimate_cdr_no_doa

"""
"
"""


def dereverb_no_doa(macro, params, array):
    print('De-reverberation with no DOA...')

    arraySTFT = array['arraySTFT']  # array['N'], array['micN'], fLen, tLen
    array['PSD'] = np.zeros(array['N'], dtype='object')
    array['crossPSD'] = np.zeros((array['N'], array['micN']), dtype='object')

    for aa in range(array['N']):
        # Estimate the PSD
        array['PSD'][aa] = estimate_psd(arraySTFT[aa], params['lambda'])

        # Get the microphone positions
        micPosition = np.asmatrix(array['positions'][aa][:, :2], dtype="float")

        # Loop over the microphones
        for mm in range(array['micN']):
            # Print progress
            ic(mm)

            # Get the next microphone index
            nextMic = (mm + 1) % array['micN']

            # Calculate the microphone distance (mics within each array)
            micDist = cdist(micPosition[mm, :], micPosition[nextMic, :])[0][0]

            # Define the coherence model
            Cnn = np.sinc(2 * params['f_Ax'] * micDist / params['c'])

            # Estimate the cross-PSD
            array['crossPSD'][aa, mm] = (estimate_cpsd(
                                     arraySTFT[aa, mm, :, :], arraySTFT[aa, nextMic, :, :], params['lambda']) /
                                     np.sqrt(array['PSD'][aa][mm, :, :] * array['PSD'][aa][nextMic, :, :]))

            # Estimate the CDR
            CDR = estimate_cdr_no_doa(array['crossPSD'][aa, mm], Cnn)  # check input dimensions
            CDR = np.maximum(np.real(CDR), 0)

            # # Calculate the weights using spectral subtraction
            # weights = spectral_subtraction(CDR, alpha, beta, mu)
            # weights = np.maximum(weights, floor_)
            # weights = np.minimum(weights, 1)
            #
            # # Calculate the binary mask
            # array.mask[aa][:, :, mm] = (weights > 0.5).astype(int)
            #
            # # Calculate the post-filter signal
            # inputSignal = np.concatenate((arraySTFT[aa][:, :, mm], arraySTFT[aa][:, :, nextMic]), axis=2)
            # postFilter = np.sqrt(np.mean(np.abs(inputSignal) ** 2, axis=2)) * np.exp(
            #     1j * np.angle(arraySTFT[aa][:, :, mm]))
            #
            # # Calculate the dereverbed STFT
            # dereverbSTFT[aa].append(weights * postFilter)
            #
            # # Debug
            # plot the istft of each dereverbered signal
            # dereverbSignal[aa].append(istft(dereverbSTFT[aa][mm], analysisWin, synthesisWin, hop, Nfft, Fs))

    return dereverbSTFT
