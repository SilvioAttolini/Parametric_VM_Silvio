function [params, source] = get_source_signal(params, source)
    fprintf('Defining source signal...\n');

    sourceSignal = cell(source.N, 1);
    sourceSTFT = cell(source.N, 1);

    for s = 1:source.N
        [tmp, oFs] = audioread([source.filePath, '/' num2str(s), '.flac']);

        start = find(tmp > 0.5 * var(tmp), 1); % where the signal is present
        stop = start + oFs * source.signalLength;
        tmp = tmp(start:stop-1, 1);
        tmp = resample(tmp, params.Fs, oFs);
        tmp = [zeros(2*params.winLength,1); tmp];

        sourceSignal{s} = tukeywin(length(tmp), 0.99)' .* tmp';
        sourceSignal{s} = normalize(sourceSignal{s}');
        sourceSignal{s} = [zeros(size(params.winLength,1)); sourceSignal{s}; zeros(size(params.winLength,1))];

        [sourceSTFT{s}, ~, source.tAx] = my_stft(sourceSignal{s}, params);

    end

    source.sourceSignal = sourceSignal;
    source.sourceSTFT = sourceSTFT;
    source.signalLength = length(sourceSignal{1}) / params.Fs;
    params.tLen = length(source.tAx);
    params.tAx = source.tAx;

end


% maybe we should add the noise to the source signals here,
        % not after the derev, so that the mics of the arrays
        % contain info about the reverberated noise
        % sourceSignal{s} = add_noise_array_signals() kinda