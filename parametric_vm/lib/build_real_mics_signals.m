function [arraySTFT, arrayDirectSTFT] = build_real_mics_signals(array, source, room, params)

    fLen = params.fLen;
    tLen = params.tLen;
    sourcePos = cell2mat(source.position');

    arraySTFT = cell(array.micN, 1);
    arrayDirectSTFT = cell(array.micN, 1);

    for iSrc = 1:source.N
        for aa = 1:array.N
            fprintf("%d", aa);
            if iSrc == 1
                arraySTFT{aa} = zeros(fLen, tLen, array.micN);
                arrayDirectSTFT{aa} = zeros(fLen, tLen, array.micN);
            end

            arrayPos = cell2mat(array.position(aa));         % Mics coordinates

            for mm = 1:array.micN

                % complete with reverb
                [~, impResp] = rir(params.c, params.Fs, sourcePos(iSrc,:), arrayPos(mm,:), room.dim, ...
                                   room.T60, params.Nfft, source.type{iSrc}, room.reflectionOrder, 3, ...
                                   source.orientation{iSrc}, false, room.diffuseTime);

                impRespFrame = repmat(impResp.', 1, tLen);
                current = source.sourceSTFT{iSrc} .* impRespFrame;
                arraySTFT{aa}(:,:,mm) = arraySTFT{aa}(:,:,mm) + current;

                % direct only
                [~, h] = rir(params.c, params.Fs, sourcePos(iSrc,:), arrayPos(mm,:), room.dim, 0, params.Nfft,...
                             source.type{iSrc}, 0, 3, source.orientation{iSrc}, false);

                hFrame = repmat(h.', 1,tLen);
                current = source.sourceSTFT{iSrc} .* hFrame;
                arrayDirectSTFT{aa}(:,:,mm) = arrayDirectSTFT{aa}(:,:,mm) + current;
            end
        end
    end
    fprintf("\n");
end
