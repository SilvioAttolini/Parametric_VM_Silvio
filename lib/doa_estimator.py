import numpy as np
from scipy.signal import find_peaks


def doa_estimator(signal, H, theta_ax, mask=None):
    if mask is None:
        mask = np.ones_like(signal)

    #sigfnal must be 4097x4 or viceversa

    # Apply the mask
    signal[~mask] = 0

    # Compute the pseudo-spectrum
    aux2 = np.tile(signal, (1, 1, len(theta_ax)))  # Repeat signal for 360
    aux2 = np.transpose(aux2, (1, 2, 0))  # Move indexes
    pseudoSpectrum = np.abs(np.squeeze(np.sum(H * aux2, axis=0)))  # OUTPUT

    # Normalize the pseudo-spectrum
    pseudoSpectrum /= np.max(pseudoSpectrum)

    meanPseudoSpectrum = np.mean(pseudoSpectrum, axis=1)

    repMeanPseudoSpectrum = np.tile(meanPseudoSpectrum, (1, 3))
    doaAx = np.tile(theta_ax, (1, 3))

    # DOA estimation and pruning
    doaPeaks, _ = find_peaks(repMeanPseudoSpectrum.ravel(), distance=5)  # , sort='descend')
    doaWeight = repMeanPseudoSpectrum.ravel()[doaPeaks]
    doa = doaAx.ravel()[doaPeaks]
    doa, indices = np.unique(doa, return_index=True)
    doaWeight = doaWeight[indices]

    return doaWeight, doa, meanPseudoSpectrum
