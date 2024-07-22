function couple_diffuses = choose_diffuse(method, array, params, cptPts, vm)

    refDiff = my_stft(cptPts.referenceComplete(:, vm), params).' - my_stft(cptPts.referenceDirect(:, vm), params).';

    switch lower(method)
        case 'bst'
            base_diffuse_A = cptPts.referenceComplete(:, vm) - cptPts.referenceDirect(:, vm);
            base_diffuse_B = cptPts.referenceComplete(:, vm+1) - cptPts.referenceDirect(:, vm+1);

        case 'avg'
            base_diffuse_A = weighted_diffuse_contributions(array, params, cptPts, vm);
            base_diffuse_B = weighted_diffuse_contributions(array, params, cptPts, vm+1);

        case 'rnd'
            [arrA, micA, arrB, micB] = choose_random(array);
            base_diffuse_A = array.meanDiffuse{arrA}(:, micA);
            base_diffuse_B = array.meanDiffuse{arrB}(:, micB);
    end

    plot_diff_diffuses(base_diffuse_A, base_diffuse_B, cptPts, params, vm, method);
    couple_diffuses = [base_diffuse_A; base_diffuse_B];
end

%    base_diffuse_A = base_diffuse_A + max(base_diffuse_A)*randn(length(base_diffuse_A),1)/1000;
