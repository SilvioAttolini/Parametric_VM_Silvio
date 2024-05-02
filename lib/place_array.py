import numpy as np
from icecream import ic as qq

"""
" This function computes the array locations according to the number of arrays
"""


def place_array(array, room):

    array['centers'] = np.empty(array['N'], dtype=object)  # center of each array
    array['positions'] = np.empty(array['N'], dtype=object)  # position of each mic in array

    # Angles and radius of overall structure
    thetas = np.arange(0, 2 * np.pi, 2 * np.pi / array['N'])
    rho = 1.7  # m

    # Compute center coordinates of each array
    center_coordinates = np.empty((array['N'], 2), dtype=object)
    center_coordinates[:, 0] = np.cos(thetas) * rho
    center_coordinates[:, 1] = np.sin(thetas) * rho

    x_y_room_dims = room['dim'][:2]
    center_coordinates = center_coordinates + x_y_room_dims / 2
    # qq(center_coordinates)

    # Microphones' displacements within each array
    thetas = np.arange(0, 2 * np.pi, 2 * np.pi / array['micN'])
    rho = array['radius']
    mic_coordinates = np.empty((array['micN'], 2), dtype=object)
    mic_coordinates[:, 0] = np.cos(thetas) * rho
    mic_coordinates[:, 1] = np.sin(thetas) * rho

    # Place the microphones in the environment
    zeros_column = np.zeros((len(mic_coordinates), 1))
    for aa in range(array['N']):
        array['centers'][aa] = np.concatenate([center_coordinates[aa], [room['z'] / 2]])  # 3axis coords
        # qq(array['centers'][aa])

        mic_coord_with_zeros = np.hstack((mic_coordinates, zeros_column))
        center_replicated = np.tile(array['centers'][aa], (array['micN'], 1))
        array['positions'][aa] = mic_coord_with_zeros + center_replicated
        # shift the position of each mic according to the new position of the center
        # qq(array['positions'][aa])

    return array
