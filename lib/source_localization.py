import numpy as np
from icecream import ic
from lib.dereverb_no_doa import dereverb_no_doa

"""
"
"""


def source_localization(macro, params, sources, array, loc_params):
    print("Localizing the sources...")

    if loc_params['dereverb']:
        dereverbSTFT = dereverb_no_doa(macro, params, array)
    else:
        dereverbSTFT = array['arraySTFT']

    return best_pos, median_pos, best_error, median_error
