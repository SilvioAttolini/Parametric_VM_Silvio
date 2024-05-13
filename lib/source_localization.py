import numpy as np
from icecream import ic
from lib.dereverb_no_doa import dereverb_no_doa
from lib.pol_to_cart import pol_to_cart
from lib.approx_min_bound_sphere_nd import approx_min_bound_sphere_nd
from lib.superdirective_filter import superdirective_filter

"""
"
"""


def source_localization(macro, params, sources, array, loc_params):
    print("Localizing the sources...")

    if loc_params['Dereverb']:
        dereverbSTFT = dereverb_no_doa(macro, params, array)
    else:
        dereverbSTFT = array['arraySTFT']

    # Normalize the center coordinates translating to the center
    array_center = array['center']
    array_center = array_center[:, :2]
    _, centerROI = approx_min_bound_sphere_nd(array_center[:, :2])
    array_center = array_center - centerROI

    print("Localization based on beamforming...")

    # nominal_mic_pos
    nominal_mic_pos = pol_to_cart(np.linspace(0, 2 * np.pi, 2 * np.pi / array['micN']), array['radius'])

    # Angles
    theta_ax = np.arange(0, 360, loc_params['stepAngle'])
    theta_ax = np.deg2rad(theta_ax)

    # superdirective filter
    sd_filter = superdirective_filter(nominal_mic_pos, theta_ax, params['f_ax'], params['c'])

    # time_frame_step
    if loc_params['secPerPosEstimation'] == -1:
        time_frame_step = 1
    else:
        _, time_frame_step = np.min(np.abs(params['t_ax'] - loc_params['secPerPosEstimation']))



    return best_pos, median_pos, best_error, median_error
