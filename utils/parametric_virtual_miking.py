import numpy as np
from icecream import ic
from utils.localize_sources import localize_sources

"""
"
"""


def parametric_virtual_miking(macro, params, sources, array, cpt_pts, spherical_p):
    print("PARAMETRIC VIRTUAL MIKING")

    sources = localize_sources(macro, params, sources, array)
    ic(sources)

    cpt_pts['completeEstimate'] = None
    cpt_pts['directEstimate'] = None
    return cpt_pts
