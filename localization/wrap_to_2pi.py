import numpy as np
from icecream import ic

"""
    Wrap angles in radians to [0, 2*pi].

    Positive multiples of 2*pi map to 2*pi, negative multiples of 2*pi map to zero.
"""


def wrap_to_2pi(lambda_angles):

    lambda_angles = np.atleast_1d(lambda_angles)

    positiveInput = lambda_angles > 0
    lambda_wrapped = np.mod(lambda_angles, 2 * np.pi)
    lambda_wrapped = np.where((lambda_wrapped == 0) & positiveInput, 2 * np.pi, lambda_wrapped)

    # If the original input was a scalar, return a scalar
    if lambda_wrapped.size == 1:
        return lambda_wrapped[0]

    return lambda_wrapped
