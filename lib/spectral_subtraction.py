import numpy as np
from icecream import ic

"""
Spectral subtraction for noise reduction.

Args:
    SNR (numpy array): Signal-to-noise ratio.
    alpha (float, optional): Over-subtraction factor. Defaults to 2.
    beta (float, optional): Spectral floor parameter. Defaults to 0.5.
    mu (float, optional): Noise overestimation factor. Defaults to 1.
    Gmin (float, optional): Minimum gain. Defaults to 0.1.
    
    alpha = 1; beta = 1;   % power subtraction
    alpha = 2; beta = 0.5; % magnitude subtraction
    alpha = 2; beta = 1;   % Wiener filter
    mu: noise overestimation
    Gmin: gain floor

Returns:
    numpy array: Weights for spectral subtraction.
"""


def spectral_subtraction(SNR, alpha=2, beta=0.5, mu=1, Gmin=0.1):

    SNR = np.maximum(SNR, 0)
    weights = np.maximum(1 - (mu / (SNR + 1)) ** beta, 0) ** alpha
    weights = np.maximum(weights, 0)
    weights = np.maximum(np.sqrt(weights), Gmin)

    return weights
