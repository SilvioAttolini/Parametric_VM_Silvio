import numpy as np
from icecream import ic
from lib.dereverb_no_doa import dereverb_no_doa
from lib.pol_to_cart import pol_to_cart
from lib.approx_min_bound_sphere_nd import approx_min_bound_sphere_nd
from lib.superdirective_filter import superdirective_filter
from utils.doas_with_weights import doas_with_weights
from utils.doas_with_weights_ray_space import doas_with_weights_ray_space
from utils.find_positions_and_errors import find_positions_and_errors

"""
"
"""


def source_localization(macro, params, sources, array, loc_params):
    print("Localizing the sources...")

    if loc_params['Dereverb']:
        dereverbSTFT = dereverb_no_doa(params, array)
    else:
        dereverbSTFT = array['arraySTFT']

    print("Localization based on beamforming...")

    # nominal mic pos
    nominal_mic_pos = np.zeros((array['micN'], 2))
    nominal_mic_pos[:, 0], nominal_mic_pos[:, 1] = pol_to_cart(np.arange(0, 2 * np.pi, 2 * np.pi / array['micN']),
                                                               array['radius'])

    # Angles axis
    theta_ax = np.arange(0, 360, loc_params['stepAngle'])
    theta_ax = np.deg2rad(theta_ax)

    # super directive filter
    sd_filter = superdirective_filter(nominal_mic_pos, theta_ax, params['f_ax'], params['c'])

    # time axis
    time_frame_step = 1
    time_axis = np.arange(0, len(array['t_ax']), time_frame_step)

    # todo: from here onwarddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

    # doas and weights
    all_doa, all_weight = doas_with_weights(sources, array, dereverbSTFT, theta_ax, sd_filter, time_frame_step,
                                            time_axis)

    # doas and weights RaySpace
    doa_ray_space, weight_ray_space = doas_with_weights_ray_space(array, all_doa, all_weight)

    print(f"Estimate source position with RANSAC in {loc_params['localizationTestTrials']} tests...")

    # Find positions and errors
    best_pos, median_pos, best_error, median_error = (
        find_positions_and_errors(sources, loc_params, doa_ray_space, weight_ray_space))

    return best_pos, median_pos, best_error, median_error
