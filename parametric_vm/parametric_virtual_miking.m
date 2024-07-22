function cptPts = parametric_virtual_miking(array, source, cptPts, params, macro, quickload3, ...
                                          quickload4, quickload5, quickload6)
    %% parametricvirtualmiking
    % This function performs virtual miking using a parametric technique.
    % Parameters:
    %   array: struct containing information on the distributed arrays.
    %   source: struct containing information on the sources.
    %   cptPts: struct containing information on the VMs.
    %
    % Mirco Pezzoli, 2021
    % 22/06/2021
    % v. 0.1

    %% Localize the sources
    source = find_source_position(array, source, params, macro, quickload3);

    % Remove reverberation from the microphone signals
    array = remove_reverb(array, source, params, macro, quickload4);

    %% Spherical harmonics expansion estimation
    sphParams = define_spherical_params(source, array);
    hCoeff = get_hCoeff(array, source, sphParams, params, macro, quickload5);

    %% Estimate the direct signal using the sph expansion
    cptPts = get_direct_signal(cptPts, hCoeff, array, source, sphParams, params, macro, quickload6);

    %% Estimate full signal with the diffuse component
    cptPts = estimate_complete_signal(cptPts, array, params);

end


%    cptPts = S.cptPts;
%    array = S.array;