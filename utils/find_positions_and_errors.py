import numpy as np
from icecream import ic
from localization.cluster_and_estimate import cluster_and_estimate
from localization.localization_error import localization_error

"""
"
"""


def find_positions_and_errors(sources, loc_params, doa_ray_space, weight_ray_space):

    sources_pos = sources['position'][:, :2]
    best_error = np.inf * np.ones(sources['N'])
    best_position = np.zeros_like(sources_pos)
    all_estimated_positions = np.zeros((sources['N'], 2, loc_params['localizationTestTrials']))

    for tst in range(loc_params['localizationTestTrials']):
        estimated_position = cluster_and_estimate(doa_ray_space, weight_ray_space, sources['N'], 1e-2).T
        if sources['N'] > 1:
            v = np.zeros(sources['N'])
            src_idx = np.zeros(sources['N'], dtype=int)
            for ss in range(sources['N']):
                distance = (sources_pos, estimated_position[ss, :])
                v[ss], idx_m = np.min(distance), np.argmin(distance)
                if idx_m != ss:
                    src_idx[ss] = idx_m
                else:
                    src_idx[ss] = ss
            if src_idx[0] == src_idx[1]:
                id_min = np.argmin(v)
                if id_min == 0:
                    src_idx[1] = (src_idx[1] + 1) % 2
                else:
                    src_idx[0] = (src_idx[0] + 1) % 2
            estimated_position = estimated_position[src_idx, :]

        loc_error = localization_error(estimated_position, sources_pos)
        if loc_error < best_error:
            best_error = loc_error
            best_position = estimated_position
        all_estimated_positions[:, :, tst] = estimated_position

    median_position = np.median(all_estimated_positions, axis=2)
    median_error = localization_error(median_position, sources_pos)

    return best_position, median_position, best_error, median_error


"""
for tst in range(localizationTest):
    # Localize for each time frame
    estimatedPosition = cluster_and_estimate(doaRaySpace.T, weightRaySpace.T, source['N'], 1e-2).T
    if source['N'] > 1:  # Two sources are present in the scene
        v = np.zeros(source['N'])
        srcIdx = np.zeros(source['N'], dtype=int)
        for ss in range(source['N']):
            # Find the closest estimated position
            distance = cdist(sourcePos, np.atleast_2d(estimatedPosition[ss, :]))
            v[ss], idxM = np.min(distance), np.argmin(distance)
            srcIdx[ss] = idxM if idxM == ss else ss
        
        if srcIdx[0] == srcIdx[1]:  # Swap indexes if necessary
            idMin = np.argmin(v)
            srcIdx[1] = (srcIdx[1] % 2) + 1 if idMin == 0 else (srcIdx[1] % 2) + 1
        
        estimatedPosition = estimatedPosition[srcIdx, :]  # Reorder!!

    localizationError = localizationerror(estimatedPosition, sourcePos)
    if localizationError < bestError:
        bestError = localizationError
        bestPosition = estimatedPosition
    
    allEstimatedPosition[:, :, tst] = estimatedPosition

medianPosition = np.median(allEstimatedPosition, axis=2)
medianError = localizationerror(medianPosition, sourcePos)
"""