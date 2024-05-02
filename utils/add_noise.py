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


def add_noise(macro, params, array, array_stft, array_direct_stft=None):
    arraySignal = np.empty((array['N'], array['micN']), dtype='object')
    arrayDirectSignal = np.empty((array['N'], array['micN']), dtype='object')
    for aa in range(array['N']):
        for mm in range(array['micN']):
            ic(aa, mm)

            # Inverse STFT to obtain time-domain signals of ground rirs convolved with input signals
            arraySignal[aa, mm], tt = custom_istft(array_stft[aa, mm, :, :], params['analysisWin'],
                                                   params['synthesisWin'], params['hop'],
                                                   params['Nfft'], params['Fs'])

            if array_direct_stft and macro['COMPUTE_DIR_PATHS']:
                arrayDirectSignal[aa, mm] = custom_istft(array_direct_stft[aa, mm, :, :], params['analysisWin'],
                                                         params['synthesisWin'], params['hop'],
                                                         params['Nfft'], params['Fs'])

            # Add noise to microphone signals
            varS = np.var(arraySignal[aa, mm])
            varN = varS / (10 ** (params['SNR'] / 10))
            noise = np.sqrt(varN) * np.random.randn(len(arraySignal[aa, mm]))
            arraySignal[aa, mm] += noise

            # Update STFT with noise
            noiseSTFT, _, _ = custom_stft(noise, params['analysisWin'], params['hop'], params['Nfft'], params['Fs'])
            array_stft[aa, mm, :, :] += noiseSTFT

            # Debug
            if macro['PRINT_NoisyArraySignal']:
                plots.plot_signal_in_time(arraySignal[aa, mm], tt, "rir (x) inputs + noise")
            # plot noisy arraySTFT
    return
