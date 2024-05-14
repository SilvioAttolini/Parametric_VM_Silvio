import numpy as np
from icecream import ic

"""
"
"""


def doas_with_weights_ray_space(array, all_doa, all_weight):

    doa_ray_space = []
    weight_ray_space = []

    array_centers = array['centers'][:, :2]

    for aa in range(array['N']):
        arrayAllDoa = np.squeeze(all_doa[:, aa, :])
        arrayAllWeight = np.squeeze(all_weight[:, aa, :])

        # Mapping doas Projective Ray Space
        arrayAllDoa = arrayAllDoa[~np.isnan(arrayAllDoa)]  # equivalent to rmmissing in MATLAB
        arrayAllWeight = arrayAllWeight[~np.isnan(arrayAllWeight)]  # equivalent to rmmissing in MATLAB

        alpha = 1
        l1s = alpha * np.sin(arrayAllDoa)
        l2s = -alpha * np.cos(arrayAllDoa)
        l3s = alpha * (array_centers[aa, 2] * np.cos(arrayAllDoa)) - (array_centers[aa, 1] * np.sin(arrayAllDoa))

        doa_ray_space.extend([[l1s[i], l2s[i], l3s[i]] for i in range(len(l1s))])
        weight_ray_space.extend(arrayAllWeight)

    #     doaRaySpace.append(np.column_stack((l1s, l2s, l3s)))  # in for
    #     weightRaySpace.append(arrayAllWeight)
    # doaRaySpace = np.row_stack(doaRaySpace)  # outside for
    # weightRaySpace = np.row_stack(weightRaySpace)

    return doa_ray_space, weight_ray_space
