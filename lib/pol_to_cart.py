import numpy as np

"""
    Converts polar coordinates to Cartesian coordinates.

    Parameters:
    ----------
    theta : float or array-like
        Angle in radians.
    rho : float or array-like
        Radial distance.

    Returns:
    -------
    x : float or ndarray
        x-coordinate in Cartesian form.
    y : float or ndarray
        y-coordinate in Cartesian form.
    """


def pol_to_cart(theta, rho):

    x = rho * np.cos(theta)
    y = rho * np.sin(theta)
    return x, y
