import numpy as np
from icecream import ic

"""
"
"""


def define_spherical_p(array):

    ic(array)

    sph_params = {
        'sourcePosition': np.array([0, 0, 0]),
        'arraySignal': 'estimate',
        'maxOrder': 1,
        'cdrMicN': array['micN'],
        'regParam': {
            'method': 'tikhonov',
            'nCond': 35},
        'type': 2
    }

    return sph_params
