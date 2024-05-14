import numpy as np
from icecream import ic
from utils.localize_sources import localize_sources
from utils.define_spherical_p import define_spherical_p
from utils.define_dereverb_params import define_dereverb_params
from lib.dereverb_array_with_doa import dereverb_array_with_doa
from lib.spherical_harmonics_estimation import spherical_harmonics_estimation
from lib.estimate_direct_signal import estimate_direct_signal

"""
"
"""


def parametric_virtual_miking(macro, params, sources, array, cpt_pts):
    print("PARAMETRIC VIRTUAL MIKING")

    # Localize the sources using ransac
    sources = localize_sources(macro, params, sources, array)

    # Remove reverberation from the microphone signals
    dereverb_params = define_dereverb_params(array)
    array = dereverb_array_with_doa(macro, params, sources, array, dereverb_params)

    # Spherical Parameters
    spherical_p = define_spherical_p(sources, array)

    # Harmonics coefficients
    h_coeff = spherical_harmonics_estimation(macro, params, sources, array, spherical_p)

    # Estimate the direct signal using the sph expansion
    cpt_pts = estimate_direct_signal(macro, params, sources, array, cpt_pts, h_coeff, spherical_p)

    # @ line 103

    return cpt_pts
