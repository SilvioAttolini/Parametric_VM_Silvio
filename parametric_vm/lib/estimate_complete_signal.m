function [completeEstimate, diffuseContribution] = estimate_complete_signal(cptPts, array, params)
    %% ESTIMATECOMPLETESIGNAL
    % This function estimate the diffuse components and computes the complete
    % signal (direct + diffuse).
    addpath(genpath('habets'));

    fprintf('Estimate the full signal (direct + diffuse)...\n');

    diffuseContribution = zeros(size(cptPts.directEstimate));
    vm = 0;
    for cc = 1:cptPts.coupleN
        curr_couple = habets(cptPts, array, params, cc);
        display(size(curr_couple));
        pause(99);

    end

    % The complete sound field is given by direct + diffuse
    completeEstimate = cptPts.directEstimate + diffuseContribution;

end






%fLen = params.fLen;
%tLen = params.tLen;
%arrayCenter = cell2mat(array.center);
%arrayCenter = arrayCenter(:,1:2);
%
%distArrayCptPts = pdist2(cptPts.position,  arrayCenter);
%
%[~, closestArray]= min(distArrayCptPts, [], 2);
%diffuseContribution = zeros(size(cptPts.directEstimate));
%
%mean3 = @(x) sqrt(mean(abs(x).^2,3));
%totalDiffuseSTFT = cellfun(mean3, array.meanDiffuseSTFT, ...
%    'UniformOutput', false);
%
%% Compute the diffuse contribution for each control point
%for mm = 1:cptPts.N
%    distFactor = (1 ./ distArrayCptPts(mm,:).');
%    distFactor = distFactor ./ sum(distFactor);
%
%    arrayIdx = closestArray(mm);
%    diffuseSum = zeros(fLen, tLen);
%
%    for dd = 1:array.N
%        diffuseSum = diffuseSum + (distFactor(dd) * totalDiffuseSTFT{dd});
%    end
%    diffuseSum = diffuseSum .* ...
%        exp(1j*angle(array.meanDiffuseSTFT{arrayIdx}(:,:,1)));
%
%    diffuseContribution(:,mm) = istft(diffuseSum, params.analysisWin, ...
%           params.synthesisWin, params.hop, params.Nfft, params.Fs);
%end