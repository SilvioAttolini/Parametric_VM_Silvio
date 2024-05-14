"""
# Macro definitions
"""


def define_macro():
    macro = {
        'modelType': 2,  # 1: 2D, 2: 3D
        'LOCALIZATION_PRS': True,  # True
        'PRINT_WIENER': False,
        'PRINT_SETUP': True,
        'PRINT_SOURCE_SIGNALS': False,
        'PRINT_GROUND_RIR_TIME': False,
        'PRINT_GROUND_arraySTFT': False,
        'PRINT_GROUND_H_TIME': False,
        'PRINT_GROUND_arrayDirectSTFT': False,
        'COMPUTE_DIR_PATHS': False,
        'PRINT_NoisyArraySignal_time': False,
        'PRINT_GROUND_VM_RIR_TIME': False,
        'PRINT_GROUND_testCompleteSTFT': False,
        'PRINT_GROUND_VM_H_TIME': False,
        'PRINT_GROUND_testDirectSTFT': False
    }
    return macro
