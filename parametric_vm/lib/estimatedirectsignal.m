function cptPts = estimatedirectsignal(cptPts, hCoef, array, source, sphParams, params, macro)
    % , array]
    %% ESTIMATEDIRECTSIGNAL
    % This function estimate the direct signal of some control points from
    % using the spherical harmonics propagation

    fLen = params.fLen;
    tLen = params.tLen;

    if ~isfield(sphParams,'cdrMicN')
        micPos = cell2mat(array.position);
        micPos = micPos(:,1:2);
        arrayEstimateSTFT = zeros(fLen, tLen, array.N*array.micN);
    else
        micPos = [];
        for aa = 1:array.N
            micL = array.position{aa}(1:sphParams.cdrMicN,1:2);
            micPos = [micPos; micL];
        end
        arrayEstimateSTFT = zeros(fLen, tLen, array.N*array.micN);
    end

    frequency = params.frequency;
    kvec = 2*pi*frequency/params.c;
    type = sphParams.type;
    if strcmp(sphParams.sourcePosition, 'median')
        sourcePos = source.medianPosition;
    elseif strcmp(dereverbParams.sourcePosition, 'best')
        sourcePos = source.bestPosition;
    else
        sourcePos = source.position;
    end

    directEstimateSTFT = zeros(fLen, tLen, cptPts.N);

    for ss = 1:source.N
        fprintf(['Estimating direct signal for source ', num2str(ss), '...\n']);
        p_idx(:,ss) = pdist2(cptPts.position(:,1:2),sourcePos(ss,1:2))>0.25;

        N = sphParams.maxOrder(ss); % Spherical harmonics max order

        if macro.modelType == 1
            start = (2*N+1)*(ss-1)+1;
            stop = (2*N+1)*ss;
            if N == 0
                tmpCoeff = squeeze(hCoef(:,start:stop,:)).';
            else
                tmpCoeff = squeeze(hCoef(:,start:stop,:));
            end
        elseif macro.modelType == 2
            start = (N+1)^2*(ss-1)+1;
            stop = (N+1)^2*ss;
            if N == 0
                tmpCoeff = squeeze(hCoef(:,start:stop,:));
            else
                tmpCoeff = squeeze(hCoef(:,start:stop,:));
            end
        end

        [outSignalCpts,outSignalCptsSTFT] = propagate(tmpCoeff,cptPts.position,sourcePos(ss,1:2), ...
                                                      N, type, kvec, params, macro.modelType);

        tt_ax = 0:1/params.Fs:1/params.Fs*size(outSignalCpts,2);
        directSourceEstimate{ss} = outSignalCpts.';
        directEstimateSTFT = directEstimateSTFT + outSignalCptsSTFT;

        [~,currentEstimate] = propagate(tmpCoeff,micPos,sourcePos(ss,1:2), N, type, kvec, params, macro.modelType);
        arrayEstimateSTFT = arrayEstimateSTFT + currentEstimate;
    end

    for mm = 1:cptPts.N
        directEstimate(:,mm) = my_istft(directEstimateSTFT(:,:,mm), params);
    end

    for mm = 1:array.N*array.micN
        arrayEstimate(:,mm) = my_istft(arrayEstimateSTFT(:,:,mm), params);
    end

    % Scale the estimate for honest evaluation
    minLength = min([size(directEstimate,1),size(array.arraySignal{1}(:,1),1)]);
    nmse = @(x) mean(sum(abs(x * arrayEstimate(1:minLength,:) - cat(2,array.meanDerev{:})).^2) ./ ...
                     sum(abs(cat(2,array.meanDerev{:}).^2)));
    bestScale = fminbnd(nmse, 0, 10);
    directEstimate = bestScale * directEstimate;

    % return
    cptPts.estimateDirectSTFT = directEstimateSTFT;
    cptPts.estimateDirect = directEstimate;
%    array.arrayEstimateSTFT = arrayEstimateSTFT;
%    array.arrayEstimate = arrayEstimate;
end
