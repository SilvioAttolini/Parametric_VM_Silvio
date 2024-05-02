from lib.place_array import place_array
from icecream import ic as qq

"""
" Place the array in the scene
"""


def define_array(room):
    array = {
        'N': 1,  # 9,            # Number of arrays
        'micN': 4,         # Number of microphone per array
        'radius': 0.04     # Radius of the array
    }

    print(f"Placing {array['N']} arrays in the room...")
    array = place_array(array, room)

    # qq(array)

    return array
