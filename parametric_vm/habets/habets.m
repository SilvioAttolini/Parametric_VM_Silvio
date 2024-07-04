function couple_signals = habets(params, cptPts, array, cc)
%    display(params);
%    display(cptPts);
%    display(array);

    Fs = params.Fs;
    c = params.c;
    K = 256;  % optimized parameter
    M = cptPts.micN; % calculate the SC between 1 vm couple at a time
    d = cptPts.distance;
    % type_nf = 'spherical'; % Type of noise field always assumed to be 3D
    L = size(cptPts.estimateDirect);
    L = L(1);

    %% Pick M mutually 'independent' babble speech input signals
    % Here we should use the non-dereverbereted array signals
    data1 = array.meanDiffuse{1};
    data1 = data1(:, 1);
    data1 = data1 + max(data1)*randn(L,1)/1000;  % adding noise
    data1 = data1(:); % Ensure data1 is a column vector

    data5 = array.meanDiffuse{5};
    data5 = data5(:, 1);
    data5 = data5 + max(data5)*randn(L,1)/1000;
    data5 = data5(:); % Ensure data2 is a column vector

    data = [data1; data5];
    data = data - mean(data);  % removes continuous contribution (?)

    babble = zeros(L,M);
    for m=1:M
        babble(:,m) = data((m-1)*L+1:m*L);
    end

    %% Generate matrix with desired spatial coherence
    ww = 2*pi*Fs*(0:K/2)/K;
    DC = zeros(M,M,K/2+1);
    for p = 1:M
        for q = 1:M
            if p == q
                DC(p,q,:) = ones(1,1,K/2+1);
            else
                DC(p,q,:) = sinc(ww*abs(p-q)*d/(c*pi));  % case 'spherical'
            end
        end
    end

    %% Generate sensor signals with desired spatial coherence
    x = mix_signals(babble,DC,'eigen');  % 'cholesky' / 'eigen'
    couple_signals = x;

    %%% Spatial Coherence evaluation
    %% Compare desired and generated coherence
    K_eval = 256;
    ww = 2*pi*Fs*(0:K_eval/2)/K_eval;

    % Calculalte STFT and PSD of all output signals
    X = stft(x,'Window',hanning(K_eval),'OverlapLength',0.75*K_eval,'FFTLength',K_eval,'Centered',false);
    X = X(1:K_eval/2+1,:,:);
    phi_x = mean(abs(X).^2,2);

    % Calculate spatial coherence of desired and generated signals % case 'spherical'
    sc_theory = sinc(ww*d/(c*pi));

    % Compute cross-PSD of x_1 and x_(m+1)
    psi_x =  mean(X(:,:,1) .* conj(X(:,:,2)),2);

    % Compute real-part of complex coherence between x_1 and x_(m+1)
    sc_generated = real(psi_x ./ sqrt(phi_x(:,1,1) .* phi_x(:,1,2))).';

    % Calculate normalized mean square error
    NMSE = 10*log10(sum(((sc_theory)-(sc_generated)).^2)./sum((sc_theory).^2));

    Freqs=0:(Fs/2)/(K/2):Fs/2;

    % Plot spatial coherence of the pair
    fig = figure('Visible', 'off');
    plot(Freqs/1000,sc_theory,'-k','LineWidth',1.5)
    hold on;
    plot(Freqs/1000,sc_generated,'-.b','LineWidth',1.5)
    hold off;
    xlabel('Frequency [kHz]');
    ylabel('Real(Spatial Coherence)');
    title(sprintf('Inter sensor distance %1.2f m',d));
    legend('Theory',sprintf('Proposed Method (NMSE = %2.1f dB)',NMSE));
    grid on;
    saveas(fig, ['output_plots/habetsSC_with_noise_couple_', num2str(cc), '.png']);
    close(fig);

    % Save babble speech
    % audiowrite('output_plots/habetsSC_with_noise.wav',x,Fs);
end
