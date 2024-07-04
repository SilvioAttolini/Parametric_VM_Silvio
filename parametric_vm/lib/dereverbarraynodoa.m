function [dereverbSTFT, dereverbSignal] = dereverbarraynodoa(array, params, macro)
%% DEREVERBARRAY
% This function computes the dereverated soundfield with no doa knowledge

    cfg.estimator = @estimate_cdr_nodoa;              % DOA-independent estimator (CDRprop3)
    dereverbSTFT = cell(array.N,1);
    dereverbSignal = cell(array.N,1);
    arraySTFT = array.arraySTFT;
    frequency = params.frequency;
    dix = 1;

    fprintf('Derevberating SF with no DOA...');
    for aa = 1:array.N
        fprintf("%d", aa);
        array.psd{aa} = estimate_psd(arraySTFT{aa}, params.lambda);
        micPosition = cell2mat(array.position(aa));
        micPosition = micPosition(:,1:2);
        for mm = 1:array.micN
            nextMic =  mod(mm,array.micN) + 1;
            micDist = pdist2(micPosition(mm,:), micPosition(nextMic,:));

            % define coherence models
            % diffuse noise coherence; not required for estimate_cdr_nodiffuse
            Cnn = sinc(2 * frequency * micDist/params.c);

            array.crossPSD{aa}(:,:,mm) = estimate_cpsd(arraySTFT{aa}(:,:,mm), ...
                arraySTFT{aa}(:,:,nextMic), params.lambda) ./ ...
                sqrt(array.psd{aa}(:,:,mm).*array.psd{aa}(:,:,nextMic));

            CDR = cfg.estimator(array.crossPSD{aa}(:,:,mm), Cnn);
            CDR = max(real(CDR),0);

            weights = spectral_subtraction(CDR, params.alpha, params.beta, params.mu);
            weights = max(weights, params.floor);
            weights = min(weights, 1);
            % From the Wiener filter get a binary mask of active TF bins
            array.mask{aa}(:,:,mm) = imbinarize(weights);

            inputSignal = cat(3, arraySTFT{aa}(:,:,mm), arraySTFT{aa}(:,:,nextMic));
            postFilter = sqrt(mean(abs(inputSignal).^2,3)) .* exp(1j*angle(arraySTFT{aa}(:,:,mm)));

            dereverbSTFT{aa}(:,:,mm) = weights .* postFilter;

            dereverbSignal{aa}(:,mm) = istft(dereverbSTFT{aa}(:,:,mm), params);

            if macro.PRINT_WIENER == true
                figure()
                subplot(2,1,1)
                imagesc(db(CDR))
                set(gca,'YDir','normal')
                caxis([-15 15])
                colorbar
                title('Estimated CDR (=SNR) [dB]')
                xlabel('frame index')
                ylabel('subband index')
                subplot(2,1,2)
                imagesc(weights)
                set(gca,'YDir','normal')
                caxis([0 1])
                colorbar
                title(['Filter gain mic: ', num2str(mm)])
                xlabel('frame index')
                ylabel('subband index')

                maxC = max(db(abs(postFilter(:))));
                minC = min(db(abs(postFilter(:))));

                figure()
                subplot(2,1,1)
                imagesc(db(abs(postFilter)), [minC, maxC])
                set(gca,'YDir','normal')
                colorbar
                title('Input of the Wiener filter [dB]')

                subplot(2,1,2)
                imagesc(db(abs(dereverbSTFT{aa,iSrc}(:,:,mm))), ...
                    [minC, maxC])
                set(gca,'YDir','normal')
                colorbar
                title('Output of the Wiener filter [dB]')
            end
        end
    end
    fprintf('\n')
end
