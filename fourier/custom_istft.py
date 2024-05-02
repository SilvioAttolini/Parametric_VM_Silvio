import numpy as np
from icecream import ic
from scipy.fft import ifft
from utils.plots import plot_istft

"""
" translated from matlab
"
"""


def custom_istft(stft_matrix, awin, swin, hop, nfft, fs):
    # awin = win
    # swin = win

    # Determine the number of signal frames
    L = stft_matrix.shape[1]
    # Length of the synthesis window
    wlen = len(swin)
    # Estimate the length of the signal vector
    xlen = wlen + (L - 1) * hop
    # Preallocate the signal vector
    x = np.zeros(xlen)

    # Reconstruct the whole spectrum
    if nfft % 2:  # Odd nfft excludes Nyquist point
        X = np.vstack([stft_matrix, np.conj(np.flipud(stft_matrix[1:, :]))])
    else:  # Even nfft includes Nyquist point
        X = np.vstack([stft_matrix, np.conj(np.flipud(stft_matrix[1:-1, :]))])

    # Columnwise IFFT
    # xw = np.real(ifft(X, n=nfft, axis=0))
    xw = np.real(np.fft.ifft(X, axis=0))
    xw = xw[:wlen, :]

    # Weighted Overlap-Add (OLA)
    for subl in range(L):
        start = subl * hop
        x[start:start + wlen] += xw[:, subl] * swin

    # Scaling of the signal
    W0 = np.sum(awin * swin)
    x *= hop / W0

    # Generation of the time vector
    t = np.arange(xlen) / fs

    # plot_istft(x, t)

    return x, t

