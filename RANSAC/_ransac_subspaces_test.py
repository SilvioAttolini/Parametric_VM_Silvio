import numpy as np
from scipy.linalg import orth
from pathlib import Path
from scipy.io import loadmat
from RANSAC.ransac_subspaces import ransac_subspaces
from RANSAC.miss_class import miss_class
np.set_printoptions(formatter={'float': '{: 0.4f}'.format})

working_directory = Path.cwd()
starting_path = working_directory.parent.parent.parent.parent.parent
outputs_folder_path = starting_path / 'inputs_and_outputs'

# Seed the random number generators for reproducibility
# np.random.seed(1)

### LAUNCH MATLAB FIRST! IT GENERATES RANDOM NUMBERS TO READ HERE ###

# Parameters
k = 4  # dimension of subspaces
K = 5  # dimension of ambient space
N = 100  # number of points in each group
n = 2  # number of groups
thresh = 0.01  # threshold for inliers
addnoise = False  # add random Gaussian noise?

# Prepare dataset
X = np.empty((K, 0))
for _ in range(n):
    basis = orth(np.random.randn(K, k))
    X = np.hstack((X, basis @ np.random.randn(k, N)))

# Add noise if asked for
if addnoise:
    X += 0.01 * np.random.randn(*X.shape)

# Ground truth
Ntruth = np.array([N] * n)

# Call RANSAC for subspace segmentation
X_path = "/home/silvio/Documenti/Poli/tesi/methods/parametric_vm/parametric_vm_local_matlab_engine/LocalMatlabParametricVM/lib/Localization/CodeRANSAC/helper_functions/matrix_X.mat"
data = loadmat(X_path)
imported_X = data['X']
# print(imported_X)
group, b = ransac_subspaces(imported_X, k, n, thresh)
print(group)

# Compute misclassification rate
missrate, index = miss_class(group, Ntruth, n)
missrate = missrate / np.sum(Ntruth)

print(f'Missclassification error: {missrate * 100}%')
