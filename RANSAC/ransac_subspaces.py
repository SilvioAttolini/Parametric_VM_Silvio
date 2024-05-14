import numpy as np
from RANSAC.ransac_fit_arbitrary_plane import ransac_fit_arbitrary_plane


def ransac_subspaces(x, d, n, t):
    """
    Use RANSAC to iteratively and robustly find subspaces.
        x : data points (K by N matrix)
        d : dimension of the subspaces to find
        n : number of subspaces
        t : threshold for RANSAC
    """
    K, N = x.shape

    # b = np.zeros((K, d, 0))
    b = np.zeros((K, d, n))
    outliers = np.arange(N)
    group = (n+1) * np.ones(N, dtype=int)  # (n) * np.ones(N, dtype=int)

    for i in range(n):
        if len(outliers) < 4:  # should never be reached since N = 200
            dist = np.zeros((N, i))
            for j in range(i):
                Pi = np.eye(K) - b[:, :, j] @ b[:, :, j].T  # mmm
                dist[:, j] = np.sum((Pi @ x)**2, axis=0)
            # print(Pi)
            # print(dist)
            mindist = np.min(dist, axis=1)
            order = np.argsort(mindist)
            outliers = order[:4]

        # print(x[:, outliers], d, t)
        bsub, ins, borth = ransac_fit_arbitrary_plane(x[:, outliers], d, t)
        # print(bsub)  # uguali nelle funcs
        # print(ins)

        # b = np.append(b, np.expand_dims(bsub, axis=2), axis=2)
        b[:, :, i] = bsub
        # b = np.concatenate(bsub, axis=2)
        group[outliers[ins]] = i +1  # i
        outliers = np.setdiff1d(outliers, outliers[ins])
        # print(b[:,:,i])
        # print(group)
        # print(outliers)
        #
        # print(i)  # sync

    return group, b
