import numpy as np
from scipy.spatial.distance import cdist


def localization_error(estimated_position, source_position):
    """
    Compute the localization error between two sources.

    Parameters:
    - estimatedPosition: [x, y] coordinates of the estimated location, numpy array of shape (n_estimated, 2)
    - sourcePosition: [x, y] coordinates of the actual location, numpy array of shape (n_sources, 2)

    Returns:
    - LE: localization error as the minimum distances of the estimated sources with respect to the actual source positions.
    """
    # Compute pairwise distances between estimated and actual positions
    dist = cdist(estimated_position, source_position)
    # Find the minimum distance to the actual source for each estimated position
    LE = np.min(dist)  # , axis=1)
    return LE
