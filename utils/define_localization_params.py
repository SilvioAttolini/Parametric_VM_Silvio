import numpy as np
from icecream import ic

"""
"
"""


def define_localization_params():

    localization_params = {
        'dereverb': True,
        'secPerPosEstimation': -1,
        'stepAngle': 1,
        'plotPRS': True,
        'localizationTestTrials': 1000
    }

    return localization_params
