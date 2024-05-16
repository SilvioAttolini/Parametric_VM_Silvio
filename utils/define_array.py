from lib.place_array import place_array
from icecream import ic

"""
" Place the array in the scene
"""


def define_array(room):
    array = {
        'N': 2,  # 9,            # Number of arrays
        'micN': 4,         # Number of microphone per array
        'R': 1.7,           # Radius of the array structure
        'radius': 0.04     # Radius of each array
    }

    print(f"\nPlacing {array['N']} arrays in the room...")
    array = place_array(array, room)

    # ic(array)

    return array
