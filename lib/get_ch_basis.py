import numpy as np


def get_ch_basis(th_ax, order, angle=None):
    if angle is not None:
        B = np.zeros((len(th_ax), order + 1))
        for n in range(order + 1):
            B[:, n] = np.cos(n * (th_ax - angle))
    else:
        Acos = np.zeros((len(th_ax), order + 1))
        Asin = np.zeros((len(th_ax), order + 1))
        for n in range(order + 1):
            Acos[:, n] = np.cos(n * th_ax)
            Asin[:, n] = np.sin(n * th_ax)
        B = np.hstack([Acos, Asin])

    return B
