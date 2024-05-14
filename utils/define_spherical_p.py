import numpy as np
from icecream import ic

"""
"
"""


def define_spherical_p(sources, array):

    sph_params = {
        'sourcePosition': "median",
        'arraySignal': 'estimate',
        'cdrMicN': array['micN'],
        'regParam_method': 'tikhonov',
        'regParam_nCond': 35,
        'type': 2
    }

    if sources['N'] == 1:
        sph_params['maxOrder'] = np.array(1)
    else:
        sph_params['maxOrder'] = np.ones_like(sources['N'])

    return sph_params
