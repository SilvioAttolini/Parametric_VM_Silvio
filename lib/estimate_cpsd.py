import numpy as np
from icecream import ic
from scipy.signal import lfilter

"""
"
"""


def estimate_cpsd(X1,X2,lambda_):
    b = [1 - lambda_]
    a = [1, -lambda_]
    X = X1 * np.conj(X2)
    s_x1_x2 = lfilter(b, a, np.abs(X) ** 2)  # , axis=1)

    return s_x1_x2
