function sphParams = define_spherical_params(source, array)

    sphParams.arraySignal = 'estimate';
    sphParams.sourcePosition = 'median';
    sphParams.maxOrder = 1;
    sphParams.cdrMicN = array.micN;
    sphParams.regParam.method = 'tikhonov';
    sphParams.regParam.nCond = 35;
    sphParams.type = 2;

    if source.N > 1
        sphParams.maxOrder = sphParams.maxOrder*ones(1:source.N);  % Spherical harmonics max order
    end

end
