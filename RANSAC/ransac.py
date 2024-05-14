import numpy as np
from scipy.spatial.distance import cdist
from scipy.io import loadmat
np.set_printoptions(formatter={'float': '{: 0.4f}'.format})


def ransac(x, s, t, feedback=0):

    maxTrials = 3000
    maxDataTrials = 100
    p = 0.99
    # M = None
    bestM = None
    trialcount = 0
    bestscore = 0
    N = 1  # dummy initialization
    npts = x.shape[1]

    # todo: fix here: use the random function instead of the imported matrix of data!
    ind_path = "/home/silvio/Documenti/Poli/tesi/methods/parametric_vm/parametric_vm_local_matlab_engine/LocalMatlabParametricVM/lib/Localization/CodeRANSAC/helper_functions/ind.mat"
    dat = loadmat(ind_path)  # cannot read during a loop
    ind = (dat['ind'])[0]
    ind = ind - 1  # correct index shift, will not be necessary afterward

    while N > trialcount:
        degenerate = True
        count = 1
        while degenerate:
            # ind = np.random.choice(npts, s, replace=False)
            #ind = np.ceil(np.random.rand(s) * npts).astype(int)
            # ind_path = "/home/silvio/Documenti/Poli/tesi/methods/parametric_vm/parametric_vm_local_matlab_engine/LocalMatlabParametricVM/lib/Localization/CodeRANSAC/helper_functions/ind.mat"
            # dat = loadmat(ind_path)  # cannot read during a loop
            # ind = (dat['ind'])[0]
            # ind = ind - 1  # correct index shift, will not be necessary afterward

            degenerate = isdegenerate(x[:, ind], s)
            if not degenerate:
                # print(x[:, ind])
                M = fitplanebase(x[:, ind])
                # if M is not None:
                #     degenerate = False
                if M.size == 0:
                    degenerate = True

            count += 1
            if count > maxDataTrials:
                raise Warning('Unable to select a nondegenerate data set')
                # break

        inliers, M = planeptdist(M, x, t)
        # print(inliers)
        # print(M)

        ninliers = len(inliers)

        if ninliers > bestscore:
            bestscore = ninliers
            bestinliers = inliers
            bestM = M

            fracinliers = ninliers / npts
            # print(fracinliers)
            # print(fracinliers**s)

            pNoOutliers = 1 - fracinliers ** s
            pNoOutliers = max(np.finfo(float).eps, pNoOutliers)
            pNoOutliers = min(1 - np.finfo(float).eps, pNoOutliers)
            N = np.log(1 - p) / np.log(pNoOutliers)
            # print(N)

        trialcount += 1
        if feedback:
            print(f'Trial {trialcount} out of {int(np.ceil(N))}', end='\r')

        if trialcount > maxTrials:
            print(f'RANSAC reached the maximum number of {maxTrials} trials')
            break

    if bestM is not None:
        M = bestM
        inliers = bestinliers
    else:
        raise Exception('RANSAC was unable to find a useful solution')

    # print(M)
    # print(inliers)
    return M, inliers


# note: gramsmithorth seems to not have a direct official
# and/or public implementation
def gramschmidt_orth(x):
    K, D = x.shape
    I = np.eye(K)
    y = x[:, 0] / np.linalg.norm(x[:, 0])
    for i in range(1, D):
        # print(y)
        if len(np.shape(y)) == 1:
            A = I - np.outer(y, y)  # np.outer(y, y) is the transl of y*y'
            # print(np.outer(y, y))
        else:
            A = I - (y.T@y)
            # print(y.T@y)
        B = x[:, i]
        # newcol_test = A@B
        # print(A)
        # print(B)
        # print(newcol_test)

        # newcol = (I - np.outer(y, y)) @ x[:, i]
        # newcol = newcol / np.linalg.norm(newcol)
        # y = np.vstack((y, newcol))
        new_row = A@B
        new_row = new_row / np.linalg.norm(new_row)
        y = np.vstack((y, new_row))
    return y


def fitplanebase(x):
    """
    Fit a plane base given exactly d points.
    The output is the matrix that gives the component of the point orthogonal to the plane.
    The configuration of the points in x is assumed to be non-degenerate.
    """
    y = gramschmidt_orth(x)
    y = y.T  # because of matlab vs python stacking
    P = np.eye(x.shape[0]) - y @ y.T
    return P


def isdegenerate(x, d):
    r = np.linalg.matrix_rank(x) < d
    return r


def planeptdist(P, x, t):
    # print(P)
    # print(x)
    # print(t)

    dist2 = np.sum((P @ x)**2, axis=0)
    inliers = np.where(dist2 < t)[0]  # warning: these are indices!!!
    M = P
    # print(dist2)
    # print(inliers)

    if len(P) == 3:
        X = P[:2] / P[2]
        X_dist = np.linalg.norm(X)
        if X_dist > np.inf or X_dist < 0.5:
            inliers = inliers[:1]
    #print(inliers)

    return inliers, M
