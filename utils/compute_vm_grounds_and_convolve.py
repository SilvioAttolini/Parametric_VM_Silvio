import numpy as np
from icecream import ic
from lib.rir import rir
from utils import plots
from fourier.custom_istft import custom_istft
from utils.tt_axis import tt_axis

"""
"
"""


def compute_vm_grounds_and_convolve(macro, params, sources, room, cpt_pts):
    fLen = params['f_len']
    tLen = params['t_len']

    testCompleteSTFT = np.zeros((cpt_pts['N'], fLen, tLen), dtype='complex128')
    arraySignal_time = np.empty((cpt_pts['N'], tt_axis(params, testCompleteSTFT[0])))

    testDirectSTFT = np.zeros((cpt_pts['N'], fLen, tLen), dtype='complex128') \
        if macro['COMPUTE_DIR_PATHS'] else None
    arrayDirectSignal_time = np.empty((cpt_pts['N'], tt_axis(params, testCompleteSTFT[0]))) \
        if macro['COMPUTE_DIR_PATHS'] else None

    for iSrc in range(sources['N']):
        for vm in range(cpt_pts['N']):
            ic(iSrc, vm)

            # Compute vms RIR within room
            rir_time, rir_freq = rir(params, room, sources, cpt_pts, [(iSrc + 1), vm], True)

            # Convolution with source signal
            impRespFrame = np.repeat(rir_freq.T, tLen, axis=1)
            current = sources['STFT'][iSrc] * impRespFrame
            testCompleteSTFT[vm, :, :] += current

            arraySignal_time[vm], _ = custom_istft(testCompleteSTFT[vm, :, :], params['analysisWin'],
                                                   params['synthesisWin'], params['hop'],
                                                   params['Nfft'], params['Fs'])

            if macro['COMPUTE_DIR_PATHS']:
                # Direct path RIR, no walls
                h_time, h_freq = rir(params, room, sources, cpt_pts, [(iSrc + 1), vm], False)

                # Convolution with sources signal
                hFrame = np.repeat(h_freq.T, tLen, axis=1)
                current = sources['STFT'][iSrc] * hFrame
                testDirectSTFT[vm, :, :] += current

                arrayDirectSignal_time[vm], _ = custom_istft(testDirectSTFT[vm, :, :], params['analysisWin'],
                                                             params['synthesisWin'], params['hop'],
                                                             params['Nfft'], params['Fs'])

            # Debug
            plots.debug_get_reference_signals(macro, sources, room, rir_time, testCompleteSTFT, arraySignal_time,
                                              testDirectSTFT, arrayDirectSignal_time, cpt_pts, iSrc, vm)

    # Store the results (rir already convolved with the input signals)
    cpt_pts['completeReferenceSTFT'] = testCompleteSTFT
    cpt_pts['completeReference_time'] = arraySignal_time

    if macro['COMPUTE_DIR_PATHS']:
        cpt_pts['directReferenceSTFT'] = testDirectSTFT
        cpt_pts['directReference_time'] = arrayDirectSignal_time

    return cpt_pts
