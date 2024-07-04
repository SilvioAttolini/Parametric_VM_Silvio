function hCoeff = get_hCoeff(array, source, sphParams, params, macro, quickload)

    if quickload
        fprintf("Retrieving direct signal spherical harmonics expansion...\n");
        load("storage/hCoeff.mat", 'hCoeff');
    else
        fprintf('Esimating direct signal spherical harmonics expansion...\n');
        hCoeff = spherical_harmonics_estimation(array, source, sphParams, params, macro);
        save("storage/hCoeff.mat", 'hCoeff', '-v7.3');
    end

end
