import numpy as np

"""
# Room settings
"""


def define_room():

    room = {'x': 5, 'y': 4, 'z': 3,
            'dim': np.array([5, 4, 3]),
            'T60': 0.4,
            'reflectionOrder': 20,
            'diffuseTime': [],  # Consider also the early reflections
            }
    room['volume'] = room['x'] * room['y'] * room['z']
    room['surface'] = room['x'] * room['z'] * 2 + room['y'] * room['z'] * 2 + room['x'] * room['y'] * 2

    return room
