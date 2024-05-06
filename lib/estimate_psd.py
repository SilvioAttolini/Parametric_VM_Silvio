import numpy as np
from scipy.signal import lfilter


def estimate_psd(X, lambda_):
    b = [1 - lambda_]
    a = [1, -lambda_]
    Sxx = lfilter(b, a, np.abs(X)**2)  # , axis=1)
    return Sxx
