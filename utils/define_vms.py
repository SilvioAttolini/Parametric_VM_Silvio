import numpy as np

"""
" create the positions where to place the vms
"""


def define_vms(sources, room):
    # Number of vm pairs, for each source
    n_vm_pairs = 2

    # Generate angles
    MAX_NUM_OF_VMS = 50
    th_ax = np.linspace(0, 2 * np.pi, MAX_NUM_OF_VMS)

    # Silvio's modification to create pairs of VMs
    jump = MAX_NUM_OF_VMS // n_vm_pairs  # must be int
    tmp1 = th_ax[0::jump]
    tmp2 = th_ax[1::jump]
    th_ax = np.array([val for pair in zip(tmp1, tmp2) for val in pair])

    # Adjust angles
    ang_dist = 1.5  # angular distance, in degrees, between the first and the second vm in the pair
    th_ax = th_ax + np.deg2rad(ang_dist)
    xx, yy = np.cos(th_ax), np.sin(th_ax)

    # Each source is surrounded by a defined number of vm pairs
    vms_pos = np.zeros((sources['N']*len(th_ax), 3), dtype=float)
    for ss in range(sources['N']):
        for vm in range(len(th_ax)):
            vms_pos[vm + ss*len(th_ax), :] = np.array([xx[vm] + sources['position'][ss + 1][0],
                                                       yy[vm] + sources['position'][ss + 1][1],
                                                       room['z']/2])

    cptPts = {'positions': vms_pos}

    # Silvio's distance calculation (to be updated)
    # @distance will be used as parameter to create the
    # ground sinc function to follow
    # vmA = cptPts['position'][0, :]
    # vmB = cptPts['position'][1, :]
    # distance = np.linalg.norm(vmA - vmB)

    return cptPts
