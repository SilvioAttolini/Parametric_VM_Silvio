import numpy as np
from RANSAC.ransac_subspaces import ransac_subspaces


def cluster_and_estimate(peaks_pos, peaks_value, num, th):
    dim = 2
    # Assuming ransac_subspaces is previously defined and returns indices of inliers for each subspace
    idx = ransac_subspaces(peaks_pos, dim, num, th)

    est_pos = np.zeros((2, num))
    # todo: check during the execution of sourcelocalization!!!
    for j in range(1, num + 1):
        # Creating a diagonal matrix of peak values where indices match j
        L = np.diag(peaks_value[idx == j]) @ peaks_pos[:, idx == j].T
        # Compute the Singular Value Decomposition
        U, S, Vt = np.linalg.svd(L.T @ L)
        # Adjust indices and division to Python's 0-based indexing
        est_pos[:, j - 1] = Vt[-1, :2] / Vt[-1, -1]

    return est_pos, idx
