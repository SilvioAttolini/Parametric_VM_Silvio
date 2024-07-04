function H = sphericalbasis(micPosition, sourcePosition, waveNumber, maxOrder, type)
    %SPHERICALBASIS Summary of this function goes here
    %   Detailed explanation goes here

    addpath(genpath('harmonicY'));

    nMic = size(micPosition, 1);
    nSource = size(sourcePosition, 1);
    H = cell(1,nSource);

    for ii = 1:nSource
        radius = pdist2(micPosition, sourcePosition(ii, :));
        dd = sourcePosition(ii,:) - micPosition;
        phi = (atan2(dd(:,2), dd(:,1)));
        phi = phi(:);

        H{ii} = zeros(nMic, (maxOrder(ii)+1)^2, length(waveNumber));
        id = 1;
        for n = 0:maxOrder(ii)
            h = sphericalhankel(n, type, radius(:)*waveNumber(:).');

            for mm = -n:n
                sphHarmonic = harmonicY(n, mm, pi/2*ones(size(phi)), phi);
                H{ii}(:,id,:) = repmat(sphHarmonic, 1,length(waveNumber)) .* h;
                id = id+1;
            end
        end
    end
    H = cell2mat(H);
end
