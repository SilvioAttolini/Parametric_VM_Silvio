function cptPts = get_direct_signal(cptPts, hCoef, array, source, sphParams, params, macro, quickload)

    if quickload
        fprintf("Retrieving the direct signal(s)...\n");
        load("storage/cptPts_direct.mat", 'cptPts');
    else
        fprintf('Estimating the direct signal(s)...\n');
        cptPts = estimatedirectsignal(cptPts, hCoef, array, source, sphParams, params, macro);
        save("storage/cptPts_direct.mat", 'cptPts', '-v7.3');
    end

end


%        load("storage/array_direct.mat", 'array');
%        S.cptPts = cptPts;
%        S.array = array;

        % save("storage/array_direct.mat", 'array', '-v7.3');  useless direct array