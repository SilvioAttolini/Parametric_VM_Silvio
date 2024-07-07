function array = get_array_signal(array, source, room, params, quickload)
    %% GETARRAYSIGNAL
    % This function computes the signals propagating the source signals to the
    % array microphones in the specified room.

    if quickload
        fprintf("Retrieving array data...\n");
        load("storage/array.mat", 'array');
    else
        fprintf("Building real mics' signals...");
        array = build_real_mics_signals(array, source, room, params);

        fprintf("\nAdding noise...");
        array = add_noise_array_signals(array, params);
        save("storage/array.mat", 'array', '-v7.3');
        fprintf("\n");
    end

end
