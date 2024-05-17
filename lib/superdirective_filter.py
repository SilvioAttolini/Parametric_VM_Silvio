import numpy as np
from scipy.spatial.distance import pdist, squareform


def superdirective_filter(micPosition, thetaAx, fAx, c):
    fLen = len(fAx)
    micsN = micPosition.shape[0]

    dl = 10**(-20/10)  # Diagonal loading
    gSteeringAll = np.zeros((micsN, len(thetaAx), fLen), dtype=complex)

    k = np.column_stack((np.cos(thetaAx), np.sin(thetaAx)))
    for mm in range(micsN):
        for aa in range(len(thetaAx)):
            gSteeringAll[mm, aa, :] = np.exp(1j * 2 * np.pi * fAx / c * np.dot(k[aa, :], micPosition[mm, :]))

    dist = squareform(pdist(micPosition))
    Gamma2 = np.zeros((micsN*micsN, fLen))

    i = 0
    for rw in range(micsN):
        for co in range(micsN):
            Gamma2[i, :] = np.sinc(2 * np.pi * fAx * dist[rw, co] / (np.pi * c))
            i += 1

    GammaRS = Gamma2.reshape(micsN, micsN, fLen)

    eye = np.eye(micsN)
    long_eye = np.zeros((micsN, micsN, fLen))
    for ff in range(fLen):
        long_eye[:, :, ff] = eye

    GammaRS = GammaRS + dl * np.max(np.max(GammaRS)) * long_eye

    h = np.zeros((micsN, len(thetaAx), fLen), dtype=complex)

    for ff in range(fLen):
        gSt = gSteeringAll[:, :, ff]
        gamma = GammaRS[:, :, ff]
        DD = np.diag(np.dot(np.conj(gSt.T), np.linalg.solve(gamma, gSt)))
        h[:, :, ff] = np.linalg.solve(gamma, gSt) / DD

    H = np.conj(h)

    return np.transpose(H, (0, 2, 1))
