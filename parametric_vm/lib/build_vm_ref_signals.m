function cptPts = build_vm_ref_signals(cptPts, source, room, params)

    tLen = params.tLen;
    fLen = params.fLen;
    time_dim = size(my_istft(source.sourceSTFT{1}, params));
    time_dim = time_dim(2);
    sourcePos = cell2mat(source.position');

    referenceComplete = zeros(time_dim, cptPts.N);
    referenceCompleteSTFT = zeros(fLen, tLen, cptPts.N);
    referenceDirect = zeros(time_dim, cptPts.N);
    referenceDirectSTFT = zeros(fLen, tLen, cptPts.N);

    for iSrc = 1:source.N
        for mm = 1:cptPts.N
            fprintf("%d", mm);

            % complete with reverb
            [referenceComplete(:,mm), referenceCompleteSTFT(:,:,mm)] = get_mic_sig(...
                        params, cptPts.position(mm,:), room, source, true, iSrc);

            % direct only
            [referenceDirect(:,mm), referenceDirectSTFT(:,:,mm)] = get_mic_sig(...
                        params, cptPts.position(mm,:), room, source, false, iSrc);
        end
    end

    cptPts.referenceComplete = referenceComplete;
    cptPts.referenceCompleteSTFT = referenceCompleteSTFT;
    cptPts.referenceDirect = referenceDirect;
    cptPts.referenceDirectSTFT = referenceDirectSTFT;
end


%for ss = 1:source.N
%    for mm = 1:cptPts.N
%        fprintf("%d", mm);
%        [complete_h_time, h] = rir(params.c, params.Fs, source.position{ss}, [cptPts.position(mm,:),room.z/2], ...
%                               room.dim, room.T60, params.Nfft, source.type{ss}, room.reflectionOrder, 3, ...
%                               source.orientation{ss}, false, room.diffuseTime);
%
%        hFrame = repmat(h.', 1,tLen);
%        current = sourceSTFT{ss} .* hFrame;
%        referenceCompleteSTFT(:,:,mm) = referenceCompleteSTFT(:,:,mm) + current;
%
%        [ir_direct_time, h] = rir(params.c, params.Fs, source.position{ss}, [cptPts.position(mm,:),room.z/2], ...
%                                  room.dim, 0, params.Nfft, source.type{ss}, 0, 3, source.orientation{ss}, false);
%
%        hFrame = repmat(h.', 1,tLen);
%        current = sourceSTFT{ss} .* hFrame;
%        referenceDirectSTFT(:,:,mm) = referenceDirectSTFT(:,:,mm) + current;
%    end
%end
%
%cptPts.referenceCompleteSTFT = referenceCompleteSTFT;
%cptPts.referenceDirectSTFT = referenceDirectSTFT;
%
%for mm = 1:cptPts.N
%    cptPts.referenceComplete(:,mm) = my_istft(referenceCompleteSTFT(:,:,mm), params);
%    cptPts.referenceDirect(:,mm) = my_istft(referenceDirectSTFT(:,:,mm), params);
%end