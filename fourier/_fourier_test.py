import numpy as np
from fourier.ext_stft import ext_stft
from fourier.custom_stft import custom_stft
from fourier.ext_istft import ext_istft
from fourier.custom_istft import custom_istft
from utils.plots import plot_signal_in_time
import librosa

file_path = "track.wav"
x, Fs = librosa.load(file_path, sr=None, mono=False)
x = x[0, :]
x_max = np.max(np.abs(x))
x = x / x_max
t = np.arange(0, len(x)) / Fs

# Plot the original time signal
plot_signal_in_time(x, t, "Base signal")

# STFT parameters
wlen = 1024
nfft = wlen
hop = wlen // 4
win = np.hanning(wlen)

# Compute STFT
STFT, ff, tt = custom_stft(x, win, hop, nfft, Fs)  # custom, STFT::513x411
STFT2, ff2, tt2 = ext_stft(x, win, hop, nfft, Fs)  # lib, STFT2::513x140
# np.mean(STFT)-np.mean(STFT2) = (5.217468486772842e-06-1.7159309860679258e-06j)

# Compute ISTFT
sig_in_time, tax = custom_istft(STFT, win, win, hop, nfft, Fs)  # custom, istft::105984
sig_in_time2, tax2 = ext_istft(STFT2, win, hop, nfft, Fs)  # lib, istft::106752, closer to original
# np.mean(sig_in_time)-np.mean(sig_in_time2) = -2.0244023750355867e-06

print("k")
