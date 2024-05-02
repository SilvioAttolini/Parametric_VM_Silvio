"""
# Macro definitions
"""


def define_macro():
    macro = {
        'modelType': 2,  # 1: 2D, 2: 3D
        'LOCALIZATION_PRS': True,
        'PRINT_WIENER': False,
        'PRINT_SETUP': False,
        'PRINT_SOURCE_SIGNALS': False,
        'PRINT_GROUND_RIR_TIME': False,
        'PRINT_GROUND_arraySTFT': False,
        'PRINT_GROUND_H_TIME': False,
        'PRINT_GROUND_arrayDirectSTFT': False,
        'COMPUTE_DIR_PATHS': False,
        'PRINT_NoisyArraySignal': False
    }
    return macro
