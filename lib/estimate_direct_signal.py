import numpy as np
from icecream import ic

"""
"
"""


def estimate_direct_signal(macro, params, sources, array, cpt_pts, h_coeff, spherical_p):
    print("Estimating direct signal...")

    """
    #
    # REMEMBER TO INCLUDE THESE LINES!!!
    #    
    
    % direct estimate @ VMs, in time
    for mm = 1:cptPts.N
        directEstimate(:,mm) = istft(directEstimateSTFT(:,:,mm), ...
            params.analysisWin, params.synthesisWin, params.hop, ...
            params.Nfft, params.Fs);
    end
    
    for mm = 1:array.N*array['micN']
        arrayEstimate(:,mm) = istft(arrayEstimateSTFT(:,:,mm), ...
            params.analysisWin, params.synthesisWin, params.hop, ...
            params.Nfft, params.Fs);
    end
    """

    return cpt_pts
