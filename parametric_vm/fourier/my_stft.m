function [STFT, f, t] = my_stft(x, params)

    [STFT, f, t] = inner_stft(x, params.win, params.hop, params.Nfft, params.Fs);

end
