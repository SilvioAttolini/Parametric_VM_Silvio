import numpy as np
from lib.get_ch_basis import get_ch_basis


def ch_to_pol(N, coeffs, orientation):
    """
    coeffs here is passed as a row vector
    """
    th_ax = np.linspace(0, 2 * np.pi, N, endpoint=False)
    B = get_ch_basis(th_ax, len(coeffs), orientation)
    r = B @ np.array([1 - np.sum(coeffs), *coeffs])
    return th_ax, r
