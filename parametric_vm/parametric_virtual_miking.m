function cptPts = parametricvirtualmiking(array, source, cptPts, params, macro, quickload3, quickload4)
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
    sphParams = define_spherical_params(source);
    hCoeff = spherical_harmonics_estimation(array, source, sphParams, params, macro);

    disp("here");
    pause(99);

    %% Estimate the direct signal using the sph expansion
    [directEstimateSTFT, directSourceEstimate, arrayEstimateSTFT] = estimatedirectsignal(cptPts, hCoeff, array, source, ...
        sphParams, params, macro);


    % direct estimate @ VMs, in time
    for mm = 1:cptPts.N
        directEstimate(:,mm) = istft(directEstimateSTFT(:,:,mm), ...
            params.analysisWin, params.synthesisWin, params.hop, ...
            params.Nfft, params.Fs);
    end

    for mm = 1:array.N*array.MicN
        arrayEstimate(:,mm) = istft(arrayEstimateSTFT(:,:,mm), ...
            params.analysisWin, params.synthesisWin, params.hop, ...
            params.Nfft, params.Fs);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    minLength = min([size(directEstimate,1),size(array.arraySignal{1}(:,1),1)]);

    nmse = @(x) mean(sum(abs(x * arrayEstimate(1:minLength,:) - ...
        cat(2,array.meanDerev{:})).^2) ./ sum(abs(cat(2,array.meanDerev{:}).^2)));
    bestScale = fminbnd(nmse, 0, 10);

    % Scale the estimate for honest evaluation
    directEstimate = bestScale * directEstimate;
    cptPts.directEstimate = directEstimate;

    %% Estimate full signal with the diffuse component
    %[completeEstimate, diffuseContribution] = estimatecompletesignal(cptPts, array, params);

    % nuovo met
    [completeEstimate, diffuseContribution] = estimateCompleteRephased(cptPts, array, params);


    for mm = 1:cptPts.N
        [directEstimate(:,mm), completeEstimate(:,mm)] = ...
            alignsignals(directEstimate(:,mm), completeEstimate(:,mm), [], ...
            'truncate');
    end

    cptPts.directEstimate = directEstimate;
    cptPts.completeEstimate = completeEstimate;

end
