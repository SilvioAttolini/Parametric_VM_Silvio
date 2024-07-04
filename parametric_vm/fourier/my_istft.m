function [x, t] = my_istft(STFT, params)
    [x, t] = inner_istft(STFT, params.win, params.win, params.hop, params.Nfft, params.Fs);
end
