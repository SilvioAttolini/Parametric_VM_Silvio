function array = add_noise_array_signals(array, params, arraySTFT, arrayDirectSTFT)

    arraySignal = cell(array.micN, 1);
    arrayDirectSignal = cell(array.micN, 1);

    dix = 1;
    for aa = 1:array.N
        fprintf("%d", aa);
        for mm = 1:array.micN
            arraySignal{aa}(:,mm) = istft(arraySTFT{aa}(:,:,mm), params);
            arrayDirectSignal{aa}(:,mm) = istft(arrayDirectSTFT{aa}(:,:,mm), params);

            varS = var(arraySignal{aa}(:,mm));          % Signal energy
            varN = varS / (10^(params.SNR/10));         % Noise energy

            % Generate microphones noise
            noise = sqrt(varN) * randn(1,  size(arraySignal{aa},1));

            % Noisy microphone signal
            arraySignal{aa}(:,mm) = arraySignal{aa}(:,mm) + noise';

            % Remove the quasi-continuous contribution
            arraySignal{aa}(:, mm) = highpass(arraySignal{aa}(:, mm), 50, params.Fs);

            % STFT the microphone signal
           noiseSTFT = stft(noise, params);
           signalSTFT = stft(arraySignal{aa}(:, mm), params);
           arraySTFT{aa}(:,:,mm) = signalSTFT + noiseSTFT;
           dix = dix + 1;
        end
    end

    array.arraySTFT = arraySTFT;
    array.arraySignal = arraySignal;
    fprintf("\n");
end
