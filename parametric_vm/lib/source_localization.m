function source = source_localization(array, source, localizationParams, params, macro)
    %% SOURCELOCALIZATION
    % This function localize the N acoustic sources using the Projective Ray
    % Space and RANSAC algorithm.

    fprintf('Localizing the source(s)...\n')
    arraySTFT = array.arraySTFT;
    frequency = params.frequency;
    tAx = params.tAx;

    if localizationParams.dereverb == true
        [dereverbSTFT, ~] = dereverbarraynodoa(array, params, macro);
    else
        dereverbSTFT = arraySTFT;
    end

    secPerPosEstimation = localizationParams.secPerPosEstimation;

    [nominalMicPos(:,1),nominalMicPos(:,2)] = pol2cart(0:2*pi/array.micN:2*pi*(1-1/array.micN), array.radius);

    stepAngle = localizationParams.stepAngle;
    thetaAx = 0:stepAngle:360-stepAngle;
    thetaAx = deg2rad(thetaAx);

    sdFilter = superdirectivefilter(nominalMicPos, thetaAx, frequency, params.c);
    if secPerPosEstimation == -1
        timeFrameStep = 1;
    else
        [~,timeFrameStep] = min(abs(tAx-secPerPosEstimation));
    end

    fprintf('Localizing source using beamforming...')

    pS = cell(array.N,1);
    timeAxis = 1:timeFrameStep:length(tAx)-timeFrameStep;
    allDoa = zeros(source.N, array.N, length(timeAxis));
    allWeight = allDoa;
    doaVal = cell(size(timeAxis));
    for aa = 1:array.N
        fprintf(['\nArray ', num2str(aa), ':'])
        not_found = 0;
        for idx = 1:length(timeAxis)
            tt = timeAxis(idx);
            if mod(idx, 10) == 0 fprintf('.'); end

            stopFrame = min(timeFrameStep, size(dereverbSTFT{aa},2));
            micSignal = dereverbSTFT{aa}(:, tt+stopFrame, :);
            mask = [];

            micSignal = squeeze(mean(micSignal, 2));
            [doaWeight, doa, pS{aa}] = doaestimator(micSignal, sdFilter, thetaAx, mask);

            % Prune external DOA
            idxPrev = mod((aa-1)-1, array.N) + 1;
            idxNext = mod((aa-1)+1, array.N) + 1;
            tmpPrev = array.center{idxPrev} - array.center{aa};
            tmpSucc = array.center{idxNext} - array.center{aa};
            angPrev = atan2(tmpPrev(2), tmpPrev(1));
            angSucc = atan2(tmpSucc(2), tmpSucc(1));
            [~, idxDoa] = removeExternalDOA(doa, angSucc, angPrev);
            doaNew = doa(idxDoa);
            doaNew = (doaNew(1:min(length(doaNew), source.N)));
            doaN = length(doaNew);

            [~, doaIdx] = intersect(wrapTo2Pi(doa), doaNew, 'stable'); % indices for doa values
            doaVal = doaWeight(doaIdx);

            if isempty(doaNew)             % NO DOA FOUND
                not_found = not_found + 1;
                doaNew = NaN * ones(1,source.N);
                doaVal = doaNew;
                doaN = source.N;
                % continue; Skip
            end

            allDoa(:,aa,idx) = doaNew';
            allWeight(:,aa,idx) = doaVal;
        end
        fprintf(', not found: %d', not_found);
    end

    arrayCenter = cell2mat(array.center);
    arrayCenter = arrayCenter(:,1:2);

    doaRaySpace = [];
    weightRaySpace = [];
    for aa = 1:array.N
        arrayAllDoa = squeeze(allDoa(:,aa,:));
        arrayAllWeight = squeeze(allWeight(:,aa,:));
        % Mapping doas Projective Ray Space
        arrayAllDoa = rmmissing(arrayAllDoa(:));
        arrayAllWeight = rmmissing(arrayAllWeight(:));
        alpha = 1;
        l1s = alpha' .* sin(arrayAllDoa) ;
        l2s = -alpha' .* cos(arrayAllDoa);
        l3s = alpha' .* ((arrayCenter(aa,2) * cos(arrayAllDoa)) ...
            - (arrayCenter(aa,1) * sin(arrayAllDoa)));
        doaRaySpace = [doaRaySpace; [l1s l2s l3s]];
        weightRaySpace=[weightRaySpace; arrayAllWeight];
    end

    if localizationParams.plotPRS == true
        figure
        scatter3(doaRaySpace(:,1), doaRaySpace(:,2), doaRaySpace(:,3));
        hold on
        [l1, l2] = ndgrid(-1:.1:1, -1:.1:1);
        sourcePos = cell2mat(source.position.');
        for ss = 1:source.N
            d = -[0,0,0]*sourcePos(ss,:)';
            l3 = (-sourcePos(ss,1)*l1 - sourcePos(ss,2)*l2);
            surf(l1,l2,l3);
        end
        title('Point in the Projective Ray Space');
    end

    localizationTest = localizationParams.localizationTest;
    sourcePos = cell2mat(source.position.');
    sourcePos = sourcePos(:,1:2);
    bestError = inf*ones(source.N,1);
    bestPosition = zeros(size(sourcePos));
    allEstimatedPosition = zeros(source.N, 2, localizationTest);

    fprintf(['\nEstimating source position with RANSAC in ',  num2str(localizationTest), ' tests...\n'])
    for tst = 1:localizationTest
        % Localize for each time frame
        estimatedPosition = (cluster_and_estimate(doaRaySpace.', weightRaySpace.', source.N, 10^-2))';

        if source.N > 1 % Two sources are present in the scene
            v = zeros(source.N,1);
            srcIdx = zeros(source.N,1);
            for ss = 1:source.N
                % Find the closest estimated position
                distance = (pdist2(sourcePos, estimatedPosition(ss,:)));
                [v(ss), idxM] = min(distance);
                if idxM ~= ss, srcIdx(ss) = idxM; else, srcIdx(ss) = ss; end
            end

            if srcIdx(1) == srcIdx(2)   % Swap indexes if necessary
                [~,idMin] = min(v);
                if idMin == 1
                    srcIdx(2) = mod(srcIdx(2),2) + 1;
                else
                    srcIdx(1) = mod(srcIdx(2),2) + 1;
                end
            end

            estimatedPosition = estimatedPosition(srcIdx,:);    % Reorder!!
        end

        localizationError = (localizationerror(estimatedPosition, sourcePos));
        if localizationError < bestError
            bestError = localizationError;
            bestPosition = estimatedPosition;
        end
        allEstimatedPosition(:,:,tst) = estimatedPosition;
    end

    medianPosition = median(allEstimatedPosition, 3);
    medianError = localizationerror(medianPosition, sourcePos);

    source.medianPosition = medianPosition;
    source.bestPosition = bestPosition;
    source.medianError = medianError;
    source.bestError = bestError;

end
