import numpy as np
from icecream import ic
from lib.rir import rir
import utils.plots as plots

"""
"
"""


def compute_rirs_and_convolve(macro, params, sources, room, array):
    fLen = params['f_len']
    tLen = params['t_len']

    arraySTFT = np.zeros((array['N'], array['micN'], fLen, tLen), dtype='complex128')
    arrayDirectSTFT = np.zeros((array['N'], array['micN'], fLen, tLen), dtype='complex128')

    for iSrc in range(sources['N']):
        for aa in range(array['N']):
            for mm in range(array['micN']):
                ic(iSrc, aa, mm)

                # Compute RIR within room
                rir_time, rir_freq = rir(params, room, sources, array, [(iSrc + 1), aa, mm], True)

                # Convolution with sources signal
                impRespFrame = np.repeat(rir_freq.T, tLen, axis=1)
                current = sources['STFT'][iSrc] * impRespFrame
                arraySTFT[aa, mm, :, :] += current

                # Store the results
                array['arraySTFT'] = arraySTFT

                if macro['COMPUTE_DIR_PATHS']:
                    # Direct path RIR, no walls
                    h_time, h_freq = rir(params, room, sources, array, [(iSrc+1), aa, mm], False)

                    # Convolution with sources signal
                    hFrame = np.repeat(h_freq.T, tLen, axis=1)
                    current = sources['STFT'][iSrc] * hFrame
                    arrayDirectSTFT[aa, mm, :, :] += current

                    array['arrayDirectSTFT'] = arrayDirectSTFT
                else:
                    h_time, arrayDirectSTFT = None, None

                # Debug
                plots.debug_get_array_signals(macro, sources, room, rir_time, arraySTFT, h_time, arrayDirectSTFT,
                                              iSrc, aa, mm)

    return array
