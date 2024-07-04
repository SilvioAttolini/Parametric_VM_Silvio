function H = superdirectivefilter(micPosition, thetaAx, fAx, c)
    %% PSEUDOSPECTRUM
    % This function computes the filter for an array over 360
    % degrees with superdirective beamforming algorithm
    %
    % Params:
    %   micPosition: the relative microphone position
    %   c: sound speed
    % Returns:
    %   H: the filter in frequency

    fLen = length(fAx);
    micPosition = double(micPosition);
    micsN = size(micPosition, 1);
    c = double(c);
    dl = 10^(-20/10);  % Diagonal loading

    % Filter definition
    gSteeringAll = zeros(micsN, length(thetaAx), fLen);     % Steering Vector
    k = [cos(thetaAx)', sin(thetaAx)'];
    for mm = 1:micsN
        for aa = 1:length(thetaAx)
            gSteeringAll(mm, aa, :) = exp(1i*2*pi*fAx/c .* (k(aa,:) * micPosition(mm,:)')).';
        end
    end

    dist = squareform(pdist(micPosition));                  % Microphone dist
    Gamma2 = zeros(micsN*micsN, fLen);                      % Cross-correlation

    for mm = 1:micsN*micsN
        Gamma2(mm,:) = sinc(2*pi*fAx * dist(mm) / (pi*c));
    end

    GammaRS = reshape(Gamma2, micsN, micsN, fLen);
    GammaRS = GammaRS + dl * max(max(GammaRS)) .* repmat(eye(micsN), 1,1, fLen);

    for ff = 1:fLen
       gSt = gSteeringAll(:,:,ff);                      % Steeering vector
       gamma = GammaRS(:,:,ff);                         % Cross-correlation
       DD = diag(gSt' * (gamma \ gSt));                 % Denominator
       h(:,:,ff) =  (gamma \ gSt) ./ DD';               % Filter!
    end
    H = conj(h);

end
