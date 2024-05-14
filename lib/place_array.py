import numpy as np
from icecream import ic

"""
" This function computes the array locations according to the number of arrays
"""


def place_array(array, room):

    # Center coordinates of each array
    thetas = np.arange(0, 2 * np.pi, 2 * np.pi / array['N'])
    rho = array['R']
    array['centers'] = np.tile(room['dim'] / 2, array['N']).reshape((array['N'], 3))
    array['centers'][:, 0] = array['centers'][:, 0] + np.cos(thetas) * rho
    array['centers'][:, 1] = array['centers'][:, 1] + np.sin(thetas) * rho

    # Microphones' displacements within each array
    thetas = np.arange(0, 2 * np.pi, 2 * np.pi / array['micN'])
    rho = array['radius']
    array['positions'] = np.zeros((array['N'], array['micN'], 3))  # position of each mic in array
    for aa in range(array['N']):
        array['positions'][aa, :, :] = np.tile(array['centers'][aa], array['micN']).reshape((array['micN'], 3))
        array['positions'][aa, :, 0] = array['positions'][aa, :, 0] + np.cos(thetas) * rho
        array['positions'][aa, :, 1] = array['positions'][aa, :, 1] + np.sin(thetas) * rho

    return array
