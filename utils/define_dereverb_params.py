import numpy as np
from icecream import ic

"""
"
"""


def define_dereverb_params(array):
    dereverb_params = {
        'sourcePosition': "median",
        'cdrMicN': array['micN'],
    }

    return dereverb_params
