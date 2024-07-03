function params = define_params()

    params.c = 342;
    params.Fs = 16000;
    params.winLength = 4096;
    params.win = hamming(params.winLength,'periodic');
    params.hop = params.winLength / 8;
    params.Nfft = 2*2^nextpow2(params.winLength);
    params.SNR = 60;
    params.SDR = inf;

    params.lambda = 0.68; % smoothing factor for PSD estimation
    params.alpha = 1;
    params.beta = 1; % magnitude subtraction
    params.mu = 1.3;
    params.floor = 10^(-30/20);

    frequency = linspace(0,params.Fs/2,params.Nfft/2+1)'; % frequency axis
    params.frequency = frequency;

    fLen = length(frequency);
    params.fLen = fLen;

end
