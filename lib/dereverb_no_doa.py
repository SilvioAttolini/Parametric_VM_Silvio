import numpy as np
from icecream import ic
from lib.estimate_cdr_no_doa import estimate_cdr_no_doa
from lib.estimate_psd import estimate_psd
from lib.estimate_cpsd import estimate_cpsd
from scipy.spatial.distance import pdist

"""
"
"""


def dereverb_no_doa(macro, params, array):
    print('De-reverberation with no DOA...')

    arraySTFT = array['arraySTFT']

    for aa in range(array['N']):
        # Estimate the PSD
        array['psd'][aa] = estimate_psd(arraySTFT[aa], params['lambda'])

        # Get the microphone positions
        micPosition = array['position'][aa][:, :2]

        # Loop over the microphones
        for mm in range(array['micN']):
            # Print progress
            ic(mm)

            # Get the next microphone index
            nextMic = (mm + 1) % array['micN']

            # Calculate the microphone distance
            micDist = pdist(micPosition[mm, :].T, micPosition[nextMic, :].T)

            # Define the coherence model
            Cnn = np.sinc(2 * params['f_Ax'] * micDist / params.c)

            # Estimate the cross-PSD
            array.crossPSD[aa][:, :, mm] = (estimate_cpsd(
                arraySTFT[aa][:, :, mm], arraySTFT[aa][:, :, nextMic], params['lambda']) /
                np.sqrt(array.psd[aa][:, :, mm] * array.psd[aa][:, :, nextMic]))

            # # Estimate the CDR
            CDR = estimator(array.crossPSD[aa][:, :, mm], Cnn)
            # CDR = np.maximum(np.real(CDR), 0)
            #
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
