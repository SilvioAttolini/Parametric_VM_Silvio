function array = build_real_mics_signals(array, source, room, params)

    fLen = params.fLen;
    tLen = params.tLen;
    time_dim = size(my_istft(source.sourceSTFT{1}, params));
    time_dim = time_dim(2);

    # todo:
    """
    " WARNING: WE DO NOT SUPERIMPOSE THE SIGNALS IN CASE OF 2 SOURCES!!!!!!!!
    " we just overwrite it!!!
    """

    for iSrc = 1:source.N
        for aa = 1:array.N
            fprintf("%d", aa);
            if iSrc == 1
                arraySignal{aa} = zeros(time_dim, array.micN);
                arraySTFT{aa} = zeros(fLen, tLen, array.micN);
                arrayDirectSignal{aa} = zeros(time_dim, array.micN);
                arrayDirectSTFT{aa} = zeros(fLen, tLen, array.micN);
            end

            arrayPos = cell2mat(array.position(aa));

            for mm = 1:array.micN
                % complete with reverb
                [arraySignal{aa}(:, mm), arraySTFT{aa}(:,:,mm)] = get_mic_sig(...
                            params, arrayPos(mm,:), room, source, true, iSrc);
                % direct only
                [arrayDirectSignal{aa}(:, mm), arrayDirectSTFT{aa}(:,:,mm)] = get_mic_sig(...
                            params, arrayPos(mm,:), room, source, false, iSrc);
            end
        end
    end

    array.arraySignal = arraySignal;
    array.arraySTFT = arraySTFT;
    array.arrayDirectSignal = arrayDirectSignal;
    array.arrayDirectSTFT = arrayDirectSTFT;
end
