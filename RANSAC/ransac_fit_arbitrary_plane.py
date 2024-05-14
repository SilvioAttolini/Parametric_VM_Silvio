import numpy as np
from scipy.linalg import svd
from RANSAC.ransac import ransac


def ransac_fit_arbitrary_plane(x, d, t):
    K, N = x.shape

    if d >= K:
        raise ValueError('Dimension requested for the plane equal or greater than the dimension of the data')

    if N < d:
        raise ValueError('Number of points less than the dimension of the hyperplane')

    # s = 3  # Minimum No of points needed to fit a plane.

    # RANSAC
    P, inliers = ransac(x, d, t, feedback=0)

    # Perform the least squares fit to the inlying points
    res = svd(x[:, inliers])
    U = res[0]

    B = U[:, :d]
    Borth = U[:, d:]

    # print(inliers)  ok (shifted index)
    # print(B)
    # print(Borth)

    return B, inliers, Borth






