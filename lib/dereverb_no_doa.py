import numpy as np
from icecream import ic
from lib.estimate_psd import estimate_psd
from lib.estimate_cpsd import estimate_cpsd
from scipy.spatial.distance import cdist
from lib.estimate_cdr_no_doa import estimate_cdr_no_doa
from lib.spectral_subtraction import spectral_subtraction
from fourier.custom_istft import custom_istft
import utils.plots as plots

"""
"
"""

DEBUG = False


def dereverb_no_doa(params, array):
    print('De-reverberation with no DOA...')

    arraySTFT = array['arraySTFT']  # array['N'], array['micN'], fLen, tLen
    array['PSD'] = np.zeros(array['N'], dtype='object')
    array['crossPSD'] = np.zeros((array['N'], array['micN']), dtype='object')
    array['mask'] = np.zeros((array['N'], array['micN'], params['f_len'], params['t_len']), dtype='object')
    de_rev_STFT = np.zeros_like(arraySTFT)
    de_rev_Signal_time = np.zeros_like(array['arraySignal_time'])

    for aa in range(array['N']):
        # Estimate the PSD
        array['PSD'][aa] = estimate_psd(arraySTFT[aa], params['lambda'])

        # Get the microphone positions
        micPosition = np.asmatrix(array['positions'][aa][:, :2], dtype="float")

        # Loop over the microphones
        for mm in range(array['micN']):
            # Print progress
            ic(aa, mm)

            # Get the next microphone index
            nextMic = (mm + 1) % array['micN']

            # Calculate the microphone distance (mics within each array)
            micDist = cdist(micPosition[mm, :], micPosition[nextMic, :])[0][0]

            # Define the coherence model
            Cnn = np.sinc(2 * params['f_ax'] * micDist / params['c'])

            # Estimate the cross-PSD
            array['crossPSD'][aa, mm] = (estimate_cpsd(
                                     arraySTFT[aa, mm, :, :], arraySTFT[aa, nextMic, :, :], params['lambda']) /
                                     np.sqrt(array['PSD'][aa][mm, :, :] * array['PSD'][aa][nextMic, :, :]))

            # Estimate the CDR
            CDR = estimate_cdr_no_doa(array['crossPSD'][aa, mm], Cnn)
            CDR = np.maximum(np.real(CDR), 0)

            # Calculate the weights using spectral subtraction
            weights = spectral_subtraction(CDR, params['alpha'], params['beta'], params['mu'])
            weights = np.maximum(weights, params['floor'])
            weights = np.minimum(weights, 1)

            # Calculate the binary mask using T/F -> 1/0
            array['mask'][aa, mm, :, :] = (weights > 0.5).astype(int)

            # Calculate the post-filter signal
            input_signal = np.array([arraySTFT[aa, mm, :, :], arraySTFT[aa, nextMic, :, :]])
            # input_signal :: [2,fLen,tLen], while matlab was [fLen,tLen, 2]
            post_filter = (np.sqrt(np.mean(np.abs(input_signal) ** 2, axis=0)) *
                           np.exp(1j * np.angle(arraySTFT[aa, mm, :, :])))

            # Calculate the de-reverbered STFT
            de_rev_STFT[aa, mm, :, :] = weights * post_filter

            # Debug
            if DEBUG:
                # plot the istft of each de-reverbered signal
                de_rev_Signal_time[aa, mm], tt = custom_istft(de_rev_STFT[aa, mm, :, :], params['analysisWin'],
                                                              params['synthesisWin'], params['hop'], params['Nfft'],
                                                              params['Fs'])

                plots.plot_signal_in_time(de_rev_Signal_time[aa, mm], tt, "Dereverbered signals in time")

    # array['derevSTFT'] = de_rev_STFT
    # array['derevSignal_time'] = de_rev_Signal_time

    return de_rev_STFT
