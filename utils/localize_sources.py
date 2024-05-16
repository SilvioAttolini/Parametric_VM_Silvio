import numpy as np
from icecream import ic
from utils.define_localization_params import define_localization_params
from lib.source_localization import source_localization

"""
"
"""


def localize_sources(macro, params, sources, array):

    sources_ref_pos = np.zeros((sources['N'], 2))
    for s in range(sources['N']):
        sources_ref_pos = sources['position'][s+1][:2]

    if macro['LOCALIZATION_PRS']:
        print("Localizing the sources...")
        loc_params = define_localization_params()
        best_pos, median_pos, best_error, median_error = source_localization(macro, params, sources, array, loc_params)
    else:
        best_pos = sources_ref_pos
        median_pos = best_pos
        best_error = 0
        median_error = 0

    print(f'    > Reference source position: {sources_ref_pos}')
    print(f'    > Best estimated source position: {best_pos}')
    print(f'    > Median estimated position: {median_pos}')
    print(f'    > Best localization error: {best_error}')
    print(f'    > Median localization error: {median_error}')

    sources['best_position'] = best_pos
    sources['median_position'] = median_pos

    return sources
