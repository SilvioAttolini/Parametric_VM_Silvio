import numpy as np
from localization.wrap_to_2pi import wrap_to_2pi


def remove_external_doa(doa, low_ang, up_ang):
    """
    Filter out DOA angles outside the specified range, considering angle wrapping.
    """
    doa = wrap_to_2pi(doa)
    low_ang = wrap_to_2pi(low_ang)
    up_ang = wrap_to_2pi(up_ang)

    if low_ang <= up_ang:
        new_doa = doa[(doa >= low_ang) & (doa <= up_ang)]
        idx = (doa >= low_ang) & (doa <= up_ang)
    else:
        doa[doa <= up_ang] += 2 * np.pi
        new_doa = doa[(doa >= low_ang) & (doa <= up_ang + 2 * np.pi)]
        idx = (doa >= low_ang) & (doa <= up_ang + 2 * np.pi)

    return new_doa, idx
