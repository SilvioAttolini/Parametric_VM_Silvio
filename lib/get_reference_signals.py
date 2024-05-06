import numpy as np
from icecream import ic
from utils.compute_vm_grounds_and_convolve import compute_vm_grounds_and_convolve

"""
"
"""


def get_reference_signals(macro, params, sources, room, cpt_pts):
    print("Computing the VMs reference signals...")

    cpt_pts = compute_vm_grounds_and_convolve(macro, params, sources, room, cpt_pts)  # OK!

    # ic(cpt_pts)

    return cpt_pts
