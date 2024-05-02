import numpy as np
from scipy.signal import stft
from utils.define_sources import define_sources
from utils.plots import plot_stft


def ext_stft(x, win, hop, nfft, fs):
    ff, tt, STFT = stft(x, fs=fs, window=win, nperseg=nfft, noverlap=hop)

    # s = define_sources()
    # stop = np.where(tt >= s['signalLength'])[0][0]

    # tt = tt[:stop]
    # STFT = STFT[:, :stop]
    # plot_stft(STFT, ff, tt)

    return STFT, ff, tt
