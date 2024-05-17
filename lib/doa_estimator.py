import numpy as np
from scipy.signal import find_peaks


def doa_estimator(signal, H, theta_ax, mask=None):
    if mask is None:
        mask = np.ones_like(signal)

    # ss = signal
    #
    # # Apply the mask signal[~mask] = 0
    # for i in range(np.shape(signal)[0]):
    #     for j in range(np.shape(signal)[1]):
    #         signal[i, j] = signal[i, j] if mask[i, j] else 0
    # # seems useless, since mask[i, j] = 1 for each i, j
    #
    # print(f"{ss==signal}")

    # Compute the pseudo-spectrum
    aux2 = np.repeat(np.expand_dims(signal, 2), len(theta_ax), axis=2)
    pseudoSpectrum = np.transpose((np.abs(np.squeeze(np.sum(H * aux2, axis=0)))), (1, 0))  # to be like matlab's
                                                                                                # 360,4097

    # Normalize the pseudo-spectrum
    pseudoSpectrum /= np.max(pseudoSpectrum)

    meanPseudoSpectrum = np.mean(pseudoSpectrum, axis=1)

    repMeanPseudoSpectrum = np.repeat(np.expand_dims(meanPseudoSpectrum, 1), 3, axis=1)
    doaAx = np.repeat(np.expand_dims(theta_ax, 1), 3, axis=1)

    # DOA estimation and pruning
    doaPeaks, _ = find_peaks(repMeanPseudoSpectrum.ravel(), distance=5)  # , sort='descend')
    doaWeight = repMeanPseudoSpectrum.ravel()[doaPeaks]
    doa = doaAx.ravel()[doaPeaks]
    doa, indices = np.unique(doa, return_index=True)
    doaWeight = doaWeight[indices]

    return doaWeight, doa  # , meanPseudoSpectrum
