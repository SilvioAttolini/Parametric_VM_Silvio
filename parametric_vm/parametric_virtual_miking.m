function cptPts = parametricvirtualmiking(array, source, cptPts, sphParams, params, macro)
%% parametricvirtualmiking
% This function performs virtual miking using a parametric technique.
% Parameters:
%   array: struct containing information on the distributed arrays. 
%   source: struct containing information on the sources. 
%   cptPts: struct containing information on the VMs.
%   sphParams: 
% 
% Mirco Pezzoli, 2021
% 22/06/2021
% v. 0.1

    %%% hereeeeeeeeeeeeeee

%% Localize the sources
sourcePos = cell2mat(source.position.');
if macro.LOCALIZATION_PRS == true
    localizationParams.dereverb = true;
    localizationParams.secPerPosEstimation = -1;
    localizationParams.stepAngle = 1;
    localizationParams.plotPRS = false;
    localizationParams.localizationTest = 1000;
    [medianPosition, bestPosition, medianError, bestError] = ...
        sourcelocalization(array, source, localizationParams, params, macro);
    
else
    bestPosition = sourcePos(:,1:2);
    medianPosition = bestPosition;
    bestError = 0;
    medianError = 0;
end
fprintf('Best estimated source position(s): \n')
disp(bestPosition)
fprintf('Reference source position(s): \n')
disp(sourcePos)
fprintf('Best localization Error: \n')
disp(bestError)
fprintf('Median estimated source position(s): \n')
disp(medianPosition)
fprintf('Median localization Error: \n')
disp(medianError)

source.bestPosition = bestPosition;
source.medianPosition = medianPosition;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Remove reverberation from the microphone signals
dereverbParams.sourcePosition = 'median';
dereverbParams.cdrMicN = array.micN;
array.cdrMicN = dereverbParams.cdrMicN;

display("before dereverb with doa");

[meanDerev, meanDerevSTFT, meanDiffuse, meanDiffuseSTFT] = dereverbarraywithdoa(array, source, ...
    dereverbParams, params, macro);

display("after dereverb with doa");

array.meanDerev = meanDerev;
array.meanDerevSTFT = meanDerevSTFT;
array.meanDiffuse = meanDiffuse;
array.meanDiffuseSTFT = meanDiffuseSTFT;


%% Spherical harmonics expansion estimation
if isempty(sphParams)
    sphParams.arraySignal = 'estimate';
    sphParams.sourcePosition = 'median';
    sphParams.maxOrder = 1;
    sphParams.cdrMicN = array.cdrMicN;
    sphParams.regParam.method = 'tikhonov';
    sphParams.regParam.nCond = 35;
    sphParams.type = 2;
    
end
if source.N > 1
    sphParams.maxOrder = sphParams.maxOrder*ones(1:source.N);  % Spherical harmonics max order
end

hCoeff = sphericalharmonicsestimation(array, source, sphParams, params, macro);


%% Estimate the direct signal using the sph expansion
[directEstimateSTFT, directSourceEstimate, arrayEstimateSTFT] = estimatedirectsignal(cptPts, hCoeff, array, source, ...
    sphParams, params, macro);


% direct estimate @ VMs, in time
for mm = 1:cptPts.N
    directEstimate(:,mm) = istft(directEstimateSTFT(:,:,mm), ...
        params.analysisWin, params.synthesisWin, params.hop, ...
        params.Nfft, params.Fs);
end

for mm = 1:array.N*array.cdrMicN
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