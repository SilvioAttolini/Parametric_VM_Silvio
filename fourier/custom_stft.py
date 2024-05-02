import numpy as np
from icecream import ic
from utils.plots import plot_stft

"""
"  translated from matlab
"""


def custom_stft(x, win, hop, nfft, fs):
    x = np.array(x, dtype=float).flatten()
    xlen = len(x)
    wlen = len(win)
    NUP = nfft // 2 + 1
    L = 1 + (xlen - wlen) // hop
    STFT = np.zeros((NUP, L), dtype=np.complex_)

    for l_sub in range(L):
        start = l_sub * hop
        end = start + wlen
        if end <= xlen:
            xw = x[start:end] * win
            X = np.fft.fft(xw, n=nfft)
            STFT[:, l_sub] = X[:NUP]

    t = (np.arange(0, L) * hop + wlen // 2) / fs
    f = np.arange(0, NUP) * fs / nfft

    # plot_stft(STFT, f, t)

    return STFT, f, t
