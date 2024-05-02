import numpy as np
import icecream as ic
import math

"""
"
"""


def sim_microphone(x, y, z, angle, mtype):
    rho = 0

    if mtype in ['b', 'c', 's', 'h']:
        if mtype == 'b':
            rho = 0
        elif mtype == 'h':
            rho = 0.25
        elif mtype == 'c':
            rho = 0.5
        elif mtype == 's':
            rho = 0.75
        var_theta = math.acos(z / math.sqrt(x ** 2 + y ** 2 + z ** 2))
        var_phi = math.atan2(y, x)
        gain = (math.sin(math.pi / 2 - angle[1]) * math.sin(var_theta) * math.cos(angle[0] - var_phi) +
                math.cos(math.pi / 2 - angle[1]) * math.cos(var_theta))
        gain = rho + (1 - rho) * gain
    else:
        gain = 1
    return gain
