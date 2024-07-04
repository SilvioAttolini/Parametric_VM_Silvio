function source = find_source_position(array, source, params, macro, quickload)

    sourcePos = cell2mat(source.position.');

    if macro.LOCALIZATION_PRS == true
        localizationParams.dereverb = true;
        localizationParams.secPerPosEstimation = -1;
        localizationParams.stepAngle = 1;
        localizationParams.plotPRS = false;
        localizationParams.localizationTest = 1000;

        if quickload
            fprintf("Retrieving source localization's info...\n")
            load("storage/source.mat", 'source');
        else
            source = source_localization(array, source, localizationParams, params, macro);
            save("storage/source.mat", 'source', '-v7.3');
        end
    else
        source.bestPosition = sourcePos(:,1:2);
        source.medianPosition = bestPosition;
        source.bestError = 0;
        source.medianError = 0;
    end

    fprintf('Reference source position(s): [%f, %f]\n', sourcePos(:, 1), sourcePos(:, 2));
    fprintf('Best estimated source position(s): [%f, %f]\n', source.bestPosition(:, 1), source.bestPosition(:, 2));
    fprintf('Best localization Error:  %f\n', source.bestError);
    fprintf('Median estimated source position(s):  [%f, %f]\n', source.medianPosition(:, 1), source.medianPosition(:, 1));
    fprintf('Median localization Error:  %f\n',source.medianError);

end
