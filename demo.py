import numpy as np
from lib.get_source_signals import get_source_signals
from lib.get_array_signals import get_array_signals
from lib.get_reference_signals import get_reference_signals
from utils.define_array import define_array
from utils.define_macro import define_macro
from utils.define_parameters import define_parameters
from utils.define_room import define_room
from utils.define_sources import define_sources, describe_sources
from utils.define_cpt_pts import define_cpt_pts
from utils.parametric_virtual_miking import parametric_virtual_miking
import utils.plots as plots
from icecream import ic

# ################################################################################# #
# ###                                  DEMO                                     ### #
# ################################################################################# #


def main() -> None:

    # Define elements
    macro = define_macro()
    params = define_parameters()
    sources = define_sources()
    room = define_room()

    # Get input signals
    sources = get_source_signals(macro, sources, params)

    # Put the sources in the room
    sources = describe_sources(sources, room)

    # Place the real mic arrays
    array = define_array(room)

    # Place the virtual mics pairs
    cpt_pts = define_cpt_pts(sources, room)

    # Plot the setup
    if macro['PRINT_SETUP']:
        plots.plot_setup(array, sources, cpt_pts, room)

    # Compute the microphone signals
    array = get_array_signals(macro, params, sources, room, array)

    # Compute the reference signals at the control points (vms)
    cpt_pts = get_reference_signals(macro, params, sources, room, cpt_pts)

    # Rebuild (estimate) the VM signals
    cpt_pts = parametric_virtual_miking(macro, params, sources, array, cpt_pts)

    print('ok')


if __name__ == '__main__':
    main()
