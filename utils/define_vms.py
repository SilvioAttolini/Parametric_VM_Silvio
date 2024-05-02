import numpy as np

"""
" create the positions where to place the vms
"""


def define_vms(sources):
    # Generate angles
    th_ax = np.linspace(0, 2 * np.pi, 50)

    # Silvio's modification to create pairs of VMs
    x_num_vms = 10
    tmp1 = th_ax[0::x_num_vms]
    tmp2 = th_ax[1::x_num_vms]
    th_ax = np.array([val for pair in zip(tmp1, tmp2) for val in pair])

    # Adjust angles
    th_ax = th_ax + np.deg2rad(1.5)
    xx, yy = np.cos(th_ax), np.sin(th_ax)

    cptPts = {'position': []}
    for ss in range(sources['N']):
        cptPts['position'].extend(
            [x + sources['position'][ss + 1][0], y + sources['position'][ss + 1][1]] for x, y in zip(xx, yy))
    cptPts['position'] = np.array(cptPts['position']).reshape(-1, 2)
    cptPts['N'] = cptPts['position'].shape[0]

    # Silvio's distance calculation
    # @distance will be used as parameter to create the
    # ground sinc function to follow
    # vmA = cptPts['position'][0, :]
    # vmB = cptPts['position'][1, :]
    # distance = np.linalg.norm(vmA - vmB)

    return cptPts
