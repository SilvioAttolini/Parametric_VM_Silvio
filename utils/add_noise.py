import numpy as np
from icecream import ic
# from fourier.ext_stft import stft
# from fourier.ext_istft import istft
from fourier.custom_stft import custom_stft
from fourier.custom_istft import custom_istft
import utils.plots as plots

"""
"
"""


def add_noise(macro, params, array):
    array_stft = array['arraySTFT']
    array_direct_stft = array['arrayDirectSTFT'] if macro['COMPUTE_DIR_PATHS'] else None

    arraySignal_time = np.empty((array['N'], array['micN']), dtype='object')
    arrayDirectSignal_time = np.empty((array['N'], array['micN']), dtype='object')

    for aa in range(array['N']):
        for mm in range(array['micN']):
            # ic(aa, mm)

            # Inverse STFT to obtain time-domain signals of ground rirs convolved with input signals
            arraySignal_time[aa, mm], tt = custom_istft(array_stft[aa, mm, :, :], params['analysisWin'],
                                                        params['synthesisWin'], params['hop'],
                                                        params['Nfft'], params['Fs'])

            if macro['COMPUTE_DIR_PATHS']:
                arrayDirectSignal_time[aa, mm], tt = custom_istft(array_direct_stft[aa, mm, :, :],
                                                                  params['analysisWin'], params['synthesisWin'],
                                                                  params['hop'], params['Nfft'], params['Fs'])

            # Add noise to microphone signals
            varS = np.var(arraySignal_time[aa, mm])
            varN = varS / (10 ** (params['SNR'] / 10))
            noise = np.sqrt(varN) * np.random.randn(len(arraySignal_time[aa, mm]))
            arraySignal_time[aa, mm] += noise

            # Add noise to the STFT
            noiseSTFT, noise_f, noise_t = custom_stft(noise, params['analysisWin'], params['hop'],
                                                      params['Nfft'], params['Fs'])
            array_stft[aa, mm, :, :] += noiseSTFT

            # Debug
            if macro['PRINT_NoisyArraySignal_time']:
                plots.plot_signal_in_time(arraySignal_time[aa, mm], tt, "rir (x) inputs + noise")
                plots.plot_stft(array_stft[aa, mm, :, :], noise_f, noise_t)

    array['arraySignal_time'] = arraySignal_time
    array['arrayDirectSignal_time'] = arrayDirectSignal_time

    return array
