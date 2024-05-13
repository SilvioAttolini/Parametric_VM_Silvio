import numpy as np
from icecream import ic

"""
    estimates the Coherent-to-Diffuse Ratio (CDR) using the complex coherence of a mixed (noisy)
    signal and the coherence of the noise component.
    :param Cxx: complex coherence of mixed (noisy) signal
    :param Cnn: coherence of noise component (real-valued)
    :return:
"""


def estimate_cdr_no_doa(Cxx, Cnn):

    # Cxx deve essere 4097x165
    # Cnn deve essere 4097x1

    # Extend Cnn to the dimension of Cxx
    Cnn = (np.tile(Cnn, (Cxx.shape[1], 1))).T

    # Cnn deve essere 4097x165

    # Limit the magnitude of Cxx to prevent numerical problems
    magnitude_threshold = 1 - 1e-10
    critical = np.abs(Cxx) > magnitude_threshold
    Cxx[critical] = magnitude_threshold * Cxx[critical] / np.abs(Cxx[critical])

    # Calculate CDR
    CDR = (-(np.abs(Cxx)**2 + Cnn**2 * np.real(Cxx)**2 - Cnn**2 * np.abs(Cxx)**2 -
             2 * Cnn * np.real(Cxx) + Cnn**2)**0.5 - np.abs(Cxx)**2 + Cnn * np.real(Cxx)) / (np.abs(Cxx)**2 - 1)

    # Ensure no negative or complex results due to numerical effects
    CDR = np.maximum(np.real(CDR), 0)

    return CDR
