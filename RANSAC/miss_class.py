import numpy as np
from itertools import permutations


def miss_class(segmentation, n_points, n_groups):
    """
    Computes the number of misclassified points in the Segmentation vector.

    Parameters:
    - Segmentation: A vector containing the label for each group, ranging from 1 to n.
    - n_points: A vector containing the number of points in each group.
    - n_groups: The number of groups.

    Returns:
    - miss: The average number of misclassified points for the best permutation.
    - index: The permutation of labels that resulted in the least number of misclassified points.
    """
    Permutations = np.array(list(permutations(range(1, n_groups + 1))))
    # print(np.shape(Segmentation))
    # if Segmentation.ndim == 1:  not needed, just pass a ndarray horizontal vector
    #     Segmentation = Segmentation.reshape(1, -1)

    # Segmentation must be a horizontal array of shape (len(group),)
    # Segmentation = np.resize(Segmentation, (len(Segmentation), 1)) nope

    if segmentation.ndim == 1:
        segmentation = np.asmatrix(segmentation)

    # print((Permutations))
    # print(np.shape(Segmentation))

    miss = np.zeros((Permutations.shape[0], segmentation.shape[0]))
    # print(np.shape(miss))

    for k in range(segmentation.shape[0]):  # Iterating over row(s) in Segmentation
        for j, perm in enumerate(Permutations):  # Iterating over each permutation
            # Initialize segment_start for slicing Segmentation
            segment_start = 0
            # First group comparison is outside the loop to match MATLAB logic
            segment_end = n_points[0]
            segment = segmentation[k, segment_start:segment_end]
            miss[j, k] = np.sum(segment != perm[0])

            # Now iterate over the remaining groups
            for i in range(1, n_groups):  # Starting from 2nd group
                segment_start = np.sum(n_points[:i])
                segment_end = segment_start + n_points[i]
                # segment = Segmentation[segment_start:segment_end, k]  # not: Segmentation[k, segment_start:segment_end]
                # segmentation is a 200x1, we were searching in the wrong axis
                segment = segmentation[k, segment_start:segment_end]
                miss[j, k] = miss[j, k] + np.sum(segment != perm[i])

                # print(miss[j,k])

    # The rest of the code to calculate minimum misclassification and index would follow

    # print(np.shape(miss))
    missed = np.min(miss, axis=0)
    missed = np.mean(missed)

    miss_min_indices = np.argmin(miss, axis=0)
    index = Permutations[miss_min_indices]

    return missed, index
