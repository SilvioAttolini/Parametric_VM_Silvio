function cptPts = estimate_complete_signal(cptPts, array, params)
    %% ESTIMATECOMPLETESIGNAL
    % This function estimate the diffuse components and computes the complete
    % signal (direct + diffuse).
    addpath(genpath('habets'));

    fprintf('Estimating the full signal (direct + diffuse)...\n');

    diffuseContribution = zeros(size(cptPts.estimateDirect));
    vm = 1;
    fprintf("couple: ");
    for cc = 1:cptPts.couplesN
        fprintf("%d", cc);
        couple_diffuse = extract_noise(array, params, cptPts, vm);
        couple_diffuse = habets(params, cptPts, couple_diffuse, cc);
        diffuseContribution(:, vm) = couple_diffuse(:, 1);  % micA of the couple
        diffuseContribution(:, vm+1) = couple_diffuse(:, 2);  % micB of the couple
        vm = vm+cptPts.micN;  % to next couple
    end
    fprintf("\n");

    % The complete sound field is given by direct + diffuse
    estimateComplete = cptPts.estimateDirect + diffuseContribution;

    for mm = 1:cptPts.N
        [estimateDirect(:,mm), estimateComplete(:,mm)] =  alignsignals(cptPts.estimateDirect(:,mm), ...
                                                          estimateComplete(:,mm), [], 'truncate');
    end

    cptPts.estimateDirect = estimateDirect;
    cptPts.estimateDiffuse = diffuseContribution;
    cptPts.estimateComplete = estimateComplete;

end
