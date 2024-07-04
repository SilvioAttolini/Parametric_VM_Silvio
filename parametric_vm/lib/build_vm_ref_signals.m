function cptPts = build_vm_ref_signals(cptPts, source, room, params)

    tLen = params.tLen;
    fLen = params.fLen;
    referenceDirectSTFT = zeros(fLen, tLen, cptPts.N);
    referenceCompleteSTFT = zeros(fLen, tLen, cptPts.N);
    sourceSTFT = source.sourceSTFT;

    for ss = 1:source.N
        for mm = 1:cptPts.N
            fprintf("%d", mm);
            [complete_h_time, h] = rir(params.c, params.Fs, source.position{ss}, [cptPts.position(mm,:),room.z/2], ...
                                   room.dim, room.T60, params.Nfft, source.type{ss}, room.reflectionOrder, 3, ...
                                   source.orientation{ss}, false, room.diffuseTime);

            hFrame = repmat(h.', 1,tLen);
            current = sourceSTFT{ss} .* hFrame;
            referenceCompleteSTFT(:,:,mm) = referenceCompleteSTFT(:,:,mm) + current;

            [ir_direct_time, h] = rir(params.c, params.Fs, source.position{ss}, [cptPts.position(mm,:),room.z/2], ...
                                      room.dim, 0, params.Nfft, source.type{ss}, 0, 3, source.orientation{ss}, false);

            hFrame = repmat(h.', 1,tLen);
            current = sourceSTFT{ss} .* hFrame;
            referenceDirectSTFT(:,:,mm) = referenceDirectSTFT(:,:,mm) + current;
        end
    end
    cptPts.referenceCompleteSTFT = referenceCompleteSTFT;
    cptPts.referenceDirectSTFT = referenceDirectSTFT;

    for mm = 1:cptPts.N
        cptPts.referenceComplete(:,mm) = my_istft(referenceCompleteSTFT(:,:,mm), params);
        cptPts.referenceDirect(:,mm) = my_istft(referenceDirectSTFT(:,:,mm), params);
    end

    fprintf("\n");
    save('storage/cptPts.mat', 'cptPts', '-v7.3');

end
