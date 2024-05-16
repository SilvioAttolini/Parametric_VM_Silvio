import numpy as np
from icecream import ic

"""
"
"""


def tt_axis(params, stft_matrix):

    L = stft_matrix.shape[1]
    wlen = len(params['synthesisWin'])
    tt_len = wlen + (L - 1) * params['hop']  # xlen

    return tt_len
