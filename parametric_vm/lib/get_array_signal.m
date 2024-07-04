function array = get_array_signal(array, source, room, params, quickload)
    %% GETARRAYSIGNAL
    % This function computes the signals propagating the source signals to the
    % array microphones in the specified room.

    if quickload
        fprintf("Retrieving array data...\n");
        load("storage/array.mat", 'array');
    else
        fprintf("Building real mics' signals...");
        [arraySTFT, arrayDirectSTFT] = build_real_mics_signals(array, source, room, params);

        fprintf("Adding noise...");
        array = add_noise_array_signals(array, params, arraySTFT, arrayDirectSTFT);

        save("storage/array.mat", 'array', '-v7.3');
    end

end
