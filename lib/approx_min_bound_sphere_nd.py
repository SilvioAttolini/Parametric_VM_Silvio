import numpy as np
from scipy.spatial import ConvexHull


def approx_min_bound_sphere_nd(X):
    """
    Find a near-optimal bounding sphere for a set of M points in
    N-dimensional space using Ritter's algorithm. In 3D, the resulting sphere
    is approximately 5% bigger than the ideal minimum radius sphere.

    Parameters:
    X -- M-by-N array of point coordinates, where N>1 and M is the number of point samples.

    Returns:
    R -- radius of the bounding sphere.
    C -- centroid of the bounding sphere.

    REFERENCES:
    [1] Ritter, J. (1990), 'An efficient bounding sphere', in Graphics Gems,
    A. Glassner, Ed. Academic Press, pp.301-303
    """

    # Basic error checking
    if X.shape[1] < 2:
        raise ValueError('Invalid entry for first input argument')

    if X.shape[0] == 1:
        return 0, X[0]

    if X.shape[0] == 2:
        C = np.mean(X, axis=0)
        R = np.linalg.norm(X[0] - X[1]) / 2
        return R, C

    # Get the convex hull of the point set
    hull = ConvexHull(X)
    X = X[hull.vertices]

    # Find points with the most extreme coordinates
    Xmin = X[np.argmin(X, axis=0)]  # , np.arange(X.shape[1])]
    Xmax = X[np.argmax(X, axis=0)]  # , np.arange(X.shape[1])]

    # Compute distance between the bounding box points
    D2 = compute_pairwise_distances(Xmin, Xmax)

    # Select the pair with the largest distance
    D2_max = np.max(D2)
    idx = np.argmax(D2)
    i, j = np.unravel_index(idx, D2.shape)
    Xmin = Xmin[i]
    Xmax = Xmax[j]

    # Initial radius (squared) and centroid
    R2 = D2_max / 4
    R = np.sqrt(R2)
    C = (Xmin + Xmax) / 2

    # Loop through the M points adjusting the position and radius of the sphere
    for i in range(X.shape[0]):
        di2 = np.sum((X[i] - C) ** 2)
        if di2 > R2:
            di = np.sqrt(di2)
            R = (R + di) / 2
            R2 = R ** 2
            dR = di - R
            C = (R * C + dR * X[i]) / di

    return R, C


def compute_pairwise_distances(Xmin, Xmax):
    # Expand dimensions to enable broadcasting for pairwise subtraction
    X1 = np.transpose(np.expand_dims(Xmin, axis=2), (0, 2, 1))
    X2 = np.transpose(np.expand_dims(Xmax, axis=2), (2, 0, 1))

    D2 = X2 - X1
    D2 = np.sum(D2 ** 2, axis=2)

    return D2
