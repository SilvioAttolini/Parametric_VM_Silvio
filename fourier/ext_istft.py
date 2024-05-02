import numpy as np
from icecream import ic
from scipy.signal import istft
from utils.define_sources import define_sources
from utils.plots import plot_istft

"""
    Inverse Short-Time Fourier Transform (ISTFT) with Python Implementation.

    Parameters:
    stft_matrix - STFT matrix (only unique points, time across columns, frequency across rows)
    awin - analysis window function
    swin - synthesis window function
    hop - hop size
    nfft - number of FFT points
    fs - sampling frequency, Hz

    Returns:
    x - signal in the time domain
    t - time vector, s
"""


def ext_istft(stft_matrix, win, hop, nfft, fs):

    tax, sig_in_time = istft(stft_matrix, fs=fs, window=win, nperseg=nfft, noverlap=hop)

    # s = define_sources()
    # stop = np.where(tax >= s['signalLength'])[0][0]

    # tax = tax[:stop]
    # sig_in_time = sig_in_time[:stop]
    # plot_istft(sig_in_time, tax)

    return sig_in_time, tax
