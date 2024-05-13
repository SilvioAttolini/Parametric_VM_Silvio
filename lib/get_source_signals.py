import numpy as np
import librosa
from scipy.signal import resample
from lib.tukeywin import tukeywin
from fourier.custom_stft import custom_stft
import utils.plots as plots
# from icecream import ic


def get_source_signals(macro, source, params):
    if source['N'] == 2:
        source['signalType'] = ['speech', 'speech']
    else:
        source['signalType'] = ['speech']

    sourceSignal = np.empty(source['N'], dtype=object)
    sourceSTFT = np.empty(source['N'], dtype=object)

    nameNum = 49
    for iSrc in range(source['N']):

        # Load the speech signal
        file_path = f"{source['filePath']}/{nameNum}.flac"
        tmp, original_Fs = librosa.load(file_path, sr=None, mono=False)
        left_channel = tmp[0, :]
        # right_channel = tmp[1, :]

        # Find where the signal is present, above the noise
        start = np.where(left_channel > 0.5 * np.var(left_channel))[0][0]
        # where it ends
        stop = start + int(original_Fs * source['signalLength'])
        # extract the useful section of the signal
        tmp = left_channel[start:stop]
        # Resample the signal to the desired sampling frequency
        tmp = resample(tmp, int(len(tmp) * params['Fs'] / original_Fs))
        # Pre-append zeros
        tmp = np.concatenate((np.zeros(2 * params['winLength']), tmp))
        # Apply a Tukey window
        source_signal = tukeywin(len(tmp), 0.99) * tmp

        # Compute the STFT
        source_STFT, _, params['t_ax'] = custom_stft(source_signal, params['analysisWin'], params['hop'],
                                                     params['Nfft'], params['Fs'])
        params['t_len'] = len(params['t_ax'])

        sourceSignal[iSrc] = source_signal
        sourceSTFT[iSrc] = source_STFT
        nameNum += 1

    source['signalLength'] = len(sourceSignal[0]) / params['Fs']
    source['STFT'] = sourceSTFT

    if macro['PRINT_SOURCE_SIGNALS']:
        time_axis = np.arange(0, len(sourceSignal[0]))
        plots.plot_signal_in_time(sourceSignal[0], time_axis, 'signal in time')

    return source
