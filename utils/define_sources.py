import numpy as np

"""
# sources' settings
"""


def define_sources():
    sources = {
        'N': 1,  # 2
        'signalType': [],
        'signalLength': 5,      # Signal length in seconds
        'filePath': './audio',
    }

    return sources


def describe_sources(sources, room):
    if sources['N'] == 1:
        sources['position'] = {1: np.array([1.75, 2, room['z'] / 2])}
        sources['orientation'] = {1: [np.pi / 4, 0]}
        sources['type'] = {1: 'c'}
        sources['coefficient'] = {1: [0.5] if sources['type'][1] == 'c' else 0}

    elif sources['N'] == 2:
        sources['position'] = {1: np.array([1.75, 2, room['z'] / 2]),
                               2: np.array([3.25, 2.75, room['z'] / 2])}
        sources['orientation'] = {1: [np.pi / 4, 0],
                                  2: [-np.pi / 2, 0]}
        sources['type'] = {1: 'c',
                           2: 'c'}
        sources['coefficient'] = {1: [0.5] if sources['type'][1] == 'c' else 0,
                                  2: [0.5] if sources['type'][2] == 'c' else 0}

    else:
        print("more than 2 sources")

    return sources
