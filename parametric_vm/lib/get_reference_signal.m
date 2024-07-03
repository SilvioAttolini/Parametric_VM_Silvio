function cptPts = get_reference_signal(cptPts, source, room, params, quickload)
    %% GET REFERENCE SIGNAL
    % This function computes the direct and the complete signal at the control points (virtual microphones).

    if quickload
        fprintf('Retrieving VMs data...\n');
        load("storage/cptPts.mat", 'cptPts');
    else
        fprintf('Building VMs reference signals...');
        cptPts = build_vm_ref_signals(cptPts, source, room, params);
    end

end
