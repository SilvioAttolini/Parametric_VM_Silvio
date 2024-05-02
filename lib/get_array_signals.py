from icecream import ic
import numpy as np
from utils.compute_rirs_and_convolve import compute_rirs_and_convolve
from utils.add_noise import add_noise
import utils.plots as plots

"""
    This function computes the signals propagating the source signals to the
    array microphones in the specified room.

    Args:
      array: Object containing array properties (e.g., microphone positions)
      source: Object containing source properties (e.g., positions, signals)
      room: Object containing room properties (e.g., dimensions, reverberation time)
      params: Object containing parameters for signal processing

    Returns:
      array: Updated object containing processed signals and RIRs
"""


def get_array_signals(macro, params, sources, room, array):
    print("Computing the microphone signals...")

    if macro['COMPUTE_DIR_PATHS']:
        arraySTFT, arrayDirectSTFT = compute_rirs_and_convolve(macro, params, sources, room, array)
        array = add_noise(macro, params, array, arraySTFT, arrayDirectSTFT)
    else:
        arraySTFT = compute_rirs_and_convolve(macro, params, sources, room, array)
        array = add_noise(macro, params, array, arraySTFT)

    return array
