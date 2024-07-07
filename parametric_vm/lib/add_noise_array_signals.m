function array = add_noise_array_signals(array, params)

    for aa = 1:array.N
        fprintf("%d", aa);
        for mm = 1:array.micN

            arraySignal = array.arraySignal;

            varS = var(arraySignal{aa}(:,mm));          % Signal energy
            varN = varS / (10^(params.SNR/10));         % Noise energy

            % Generate microphones noise
            noise = sqrt(varN) * randn(1,  size(arraySignal{aa},1));

            % Noisy microphone signal
            arraySignal{aa}(:,mm) = arraySignal{aa}(:,mm) + noise';

            % Remove the quasi-continuous contribution
            % tic;
%            min_f = 50; % Hz
%            arraySignal{aa}(:, mm) = highpass(arraySignal{aa}(:, mm), min_f, params.Fs);  % very slow, almost 1 sec
            %disp(toc);

            % STFT the noisy microphone signal
%            noiseSTFT = my_stft(noise, params);
%            signalSTFT = my_stft(arraySignal{aa}(:, mm), params);
%            arraySTFT{aa}(:,:,mm) = signalSTFT + noiseSTFT;
            arraySTFT{aa}(:,:,mm) = my_stft(arraySignal{aa}(:, mm), params);
        end
    end

    array.arraySignal = arraySignal;
    array.arraySTFT = arraySTFT;
end
