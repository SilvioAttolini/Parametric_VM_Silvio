import numpy as np
from icecream import ic
from utils.compute_vm_grounds_and_convolve import compute_vm_grounds_and_convolve

"""
"
"""


STORE = False


def get_reference_signals(macro, params, sources, room, cpt_pts):
    print("Computing the VMs reference signals...")

    if STORE:
        cpt_pts = compute_vm_grounds_and_convolve(macro, params, sources, room, cpt_pts)

        print("    > Storing...")
        np.save('debug_storage/completeReferenceSTFT.npy', cpt_pts['completeReferenceSTFT'])
        np.save('debug_storage/completeReference_time.npy', cpt_pts['completeReference_time'])

    else:
        print("    > Retrieving...")
        cpt_pts['completeReferenceSTFT'] = np.load('debug_storage/completeReferenceSTFT.npy', allow_pickle=True)
        cpt_pts['completeReference_time'] = np.load('debug_storage/completeReference_time.npy', allow_pickle=True)

    return cpt_pts
