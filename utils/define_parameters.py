import numpy as np

"""
# Global parameters
"""


def define_parameters():

    params = {
        'c': 342,
        'Fs': 16000,
        'winLength': 4096,
        'hop': 4096 // 8,
        'SNR': 60,
        'SDR': np.inf,
        'lambda': 0.68,  # smoothing factor for PSD estimation
        'alpha': 1,
        'beta': 1,  # magnitude subtraction
        'mu': 1.3,
        'floor': 10 ** (-30 / 20),
        'Nfft': 0  # to be calculated
    }
    next_ = pow(2, np.ceil(np.log(params['winLength'])/np.log(2)))
    params['Nfft'] = int(2*next_)
    params['analysisWin'] = np.hamming(params['winLength'])
    params['synthesisWin'] = np.hamming(params['winLength'])

    # frequency axis
    params['f_ax'] = np.linspace(0, params['Fs'] // 2, params['Nfft'] // 2 + 1)
    params['f_len'] = len(params['f_ax'])

    return params
