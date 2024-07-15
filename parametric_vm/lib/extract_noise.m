function couple_diffuse = extract_noise(array, params, cptPts, vm)

    method = "avg";  %  "bst", "avg", "rnd"
    couple_diffuse = choose_diffuse(method, array, params, cptPts, vm);
end


function couple_diffuses = choose_diffuse(method, array, params, cptPts, vm)

    switch lower(method)
        case 'bst'
            % best cases
            base_diffuse_A = cptPts.referenceComplete(:, vm) - cptPts.referenceDirect(:, vm);
            base_diffuse_A = base_diffuse_A + max(base_diffuse_A)*randn(length(base_diffuse_A),1);
            base_diffuse_B = cptPts.referenceComplete(:, vm+1) - cptPts.referenceDirect(:, vm+1);
            base_diffuse_B = base_diffuse_A + max(base_diffuse_B)*randn(length(base_diffuse_B),1);

        case 'avg'
            % weighted average
            base_diffuse_A = propagate_diffuse_contributions(array, params, cptPts, vm);
            base_diffuse_A = base_diffuse_A + max(base_diffuse_A)*randn(length(base_diffuse_A),1)/1000;
            base_diffuse_B = propagate_diffuse_contributions(array, params, cptPts, vm+1);
            base_diffuse_B = base_diffuse_B + max(base_diffuse_B)*randn(length(base_diffuse_B),1)/1000;

        case 'rnd'
            % random choice
            [arrA, micA, arrB, micB] = choose_random(array);
            base_diffuse_A = array.meanDiffuse{arrA}(:, micA);
            base_diffuse_A = base_diffuse_A + max(base_diffuse_A)*randn(length(base_diffuse_A),1)/1000;
            base_diffuse_B = array.meanDiffuse{arrB}(:, micB);
            base_diffuse_B = base_diffuse_B + max(base_diffuse_B)*randn(length(base_diffuse_B),1)/1000;
    end

    plot_base_diffuses(base_diffuse_A, base_diffuse_B, cptPts, params, vm, method);
    couple_diffuses = [base_diffuse_A; base_diffuse_B];
end


function weighted_diffuse = propagate_diffuse_contributions(array, params, cptPts, vm)

    positions = cell2mat(array.position);
    dists_realMics_vm = pdist2(cptPts.position(vm,1:2),  positions(:, 1:2));
%    display(dists_realMics_vm);

    % Calculate weights (inverse of distances) and Normalize weights to sum to 1
    weights = 1 ./ dists_realMics_vm;
    weights = weights / sum(weights);
%    display(weights);

    tLen = length(array.meanDiffuse{1}(:,1));
    diffuses_before_travel = zeros(tLen, array.N*array.micN);
    diffuses_after_travel = zeros(tLen, array.N*array.micN);
    mic = 1;
    for aa = 1:array.N
        for mm = 1:array.micN
            diffuses_before_travel(:, mic) = array.meanDiffuse{aa}(:,mm);
            diffuses_after_travel(:, mic) = diffuses_before_travel(:, mic) * weights(mic);
            mic = mic + 1;
        end
    end

    % Calculate contribution percentages
    contributions = weights * 100;

    filename = sprintf('output_plots/Contribution_of_real_mics_to_vm_Diffuse_%d.png', vm);
    % Plot contributions
    fig = figure('Visible', 'off');
    bar(contributions);
    xlabel('Microphone');
    ylabel('Contribution (%)');
    title('Contribution of real mics to vm Diffuse');
    grid on;
    saveas(fig, filename);
    close(fig);

    weighted_diffuse = sum(diffuses_after_travel(:, 2));
end


function [arrA, micA, arrB, micB] = choose_random(array)

    arrA = randi([1, array.N]);
    micA = randi([1, array.micN]);

    % ensure that we use a different starting noise for each mic of the couple
    searching = true;
    while searching
        arrB = randi([1, 9]);
        if arrB ~= arrA
            micB = randi([1, 4]);
            searching = false;
        else
            micB = randi([1, 4]);
            if micB ~= micA
                searching = false;
            end
        end
    end

end


function plot_base_diffuses(base_diffuse_A, base_diffuse_B, cptPts, params, vm, method)

    switch lower(method)
        case 'bst'
            t1 = sprintf('Complete vs Diffuse best case %d', vm);
            t2 = sprintf('Complete vs Diffuse best case %d', vm+1);
            filename = sprintf('output_plots/Complete_vs_Diffuse_best_case_%d_%d.png', vm, vm+1);
        case 'avg'
            t1 = sprintf('Complete vs Diffuse avg %d', vm);
            t2 = sprintf('Complete vs Diffuse avg %d', vm+1);
            filename = sprintf('output_plots/Complete_vs_Diffuse_avg_%d_%d.png', vm, vm+1);
        case 'rnd'
            t1 = sprintf('Complete vs Diffuse rnd %d', vm);
            t2 = sprintf('Complete vs Diffuse rnd %d', vm+1);
            filename = sprintf('output_plots/Complete_vs_Diffuse_rnd_%d_%d.png', vm, vm+1);
%            filename = sprintf('output_plots/Complete_vs_NF_rnd_%d%d_%d%d.png', arrA, micA, arrB, micB);
    end


    display(params);

    tt = linspace(0, params.tLen, length(base_diffuse_A));

    fig = figure('Visible', 'off');
    subplot(2,1,1);
    plot(tt, cptPts.referenceComplete(:, vm),'-k','LineWidth',1)
    hold on;
    plot(base_diffuse_A,'-r','LineWidth',1)
    hold off;
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(t1);
    legend('Complete', 'Diffuse');
    ylim([-1, 1]);
    grid on;
    subplot(2,1,2);
    plot(tt, cptPts.referenceComplete(:, vm+1),'-k','LineWidth',1)
    hold on;
    plot(base_diffuse_B,'-r','LineWidth',1)
    hold off;
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(t2);
    legend('Complete', 'Diffuse');
    ylim([-1, 1]);
    grid on;
    saveas(fig, filename);
    close(fig);
end



%function delay = phase_delay(dist, freqs, params)
%
%    delay = exp(-1i*dist*2*pi*freqs/params.c);
%end


%function averaged_diffuses = propagate_diffuse_contributions(array, params, cptPts, vm)
%
%    % to exploit fft use a number of freqs equal to the length of the time signal
%    tLen = length(array.meanDiffuse{1}(:,1));
%    fLen = tLen;
%    freq = linspace(0,params.Fs/2,fLen/2);
%    freqs = [freq, flip(freq)];
%
%    diffuses_after_travel = zeros(tLen, array.N*array.micN);
%
%    mic = 1;
%    for aa = 1:array.N
%        for mm = 1:array.micN
%
%            mic_pos = array.position{aa}(mm, 1:2);
%            vm_pos = cptPts.position(vm,1:2);
%            dist = norm(mic_pos-vm_pos);
%
%            s_before_travel = array.meanDiffuse{aa}(:,mm);
%%            S_before_travel = fft(s_before_travel, fLen);
%%            S_after_travel = apply_stokes(S_before_travel, freqs, dist, params) .* phase_delay(dist, freqs, params);
%%            s_after_travel = real(ifft(S_after_travel, fLen));
%%
%%            diffuses_after_travel(:, mic) = s_after_travel;
%            diffuses_after_travel(:, mic) = s_before_travel;
%
%%            plot(s_before_travel);
%%            pause(5);
%%            plot(s_after_travel);
%%            pause(10);
%            mic = mic + 1;
%        end
%    end
%
%    averaged_diffuses = mean(diffuses_after_travel, 2);  % signals already weighted and delayed, then avg
%
%end


%function S_attenuated = apply_stokes(S, freqs, dist, params)
%
%    %%%
%    % https://en.wikipedia.org/wiki/Stokes%27s_law_of_sound_attenuation
%    %
%    % Here we attenuate the contribution of each frequency bin
%    %
%    %%%
%
%    mu = 16.82; %*10^-6;  % Dynamic viscosity, [Pa s] at 20 °C
%    rho = 1.225;  % Density of air, [kg/m^3]
%    c = params.c;  % Speed of sound, 342 [m/s]
%
%    S_attenuated = zeros(size(S));
%%    for i = 1:freqs
%%        f = freqs(i);
%%        S_attenuated(1, i) = S(1, i) * exp(- (8*mu*pi^2)*f^2*dist / (3*rho*c^3));  % stoke's eq
%%    end
%%    display(exp(- (8*mu*pi^2)*freqs(1)^2*dist / (3*rho*c^3)));
%%    display(freqs(1));
%%    display(exp(- (8*mu*pi^2)*freqs(100)^2*dist / (3*rho*c^3)));
%%    display(freqs(100));
%%    display(exp(- (8*mu*pi^2)*freqs(1000)^2*dist / (3*rho*c^3)));
%%    display(freqs(1000));
%%    display(exp(- (8*mu*pi^2)*freqs(1000)^2*dist / (3*rho*c^3)));
%%    display(freqs(10000));
%
%    S_attenuated = S;
%%    pause(2);
%%    plot(abs(S));
%%    pause(10);
%%    plot(abs(S_attenuated));
%%    pause(10);
%
%    S_attenuated = S_attenuated.';
%end



%function S_attenuated = apply_stokes(S, freqs, dist, params)
%
%    %%%
%    % https://en.wikipedia.org/wiki/Stokes%27s_law_of_sound_attenuation
%    %
%    % Here we attenuate the contribution of each frequency bin
%    %
%    %%%
%
%    mu = 16.82; %*10^-6;  % Dynamic viscosity, [Pa s] at 20 °C
%    rho = 1.225;  % Density of air, [kg/m^3]
%    c = params.c;  % Speed of sound, 342 [m/s]
%
%    S_attenuated = zeros(size(S));
%%    for i = 1:freqs
%%        f = freqs(i);
%%        S_attenuated(1, i) = S(1, i) * exp(- (8*mu*pi^2)*f^2*dist / (3*rho*c^3));  % stoke's eq
%%    end
%%    display(exp(- (8*mu*pi^2)*freqs(1)^2*dist / (3*rho*c^3)));
%%    display(freqs(1));
%%    display(exp(- (8*mu*pi^2)*freqs(100)^2*dist / (3*rho*c^3)));
%%    display(freqs(100));
%%    display(exp(- (8*mu*pi^2)*freqs(1000)^2*dist / (3*rho*c^3)));
%%    display(freqs(1000));
%%    display(exp(- (8*mu*pi^2)*freqs(1000)^2*dist / (3*rho*c^3)));
%%    display(freqs(10000));
%
%    S_attenuated = S;
%%    pause(2);
%%    plot(abs(S));
%%    pause(10);
%%    plot(abs(S_attenuated));
%%    pause(10);
%
%    S_attenuated = S_attenuated.';
%end


%    arrayCenter = cell2mat(array.center);  % centers
%    arrayCenter = arrayCenter(:,1:2);
%    dists_vms_arrCentr = pdist2(cptPts.position(vm:vm+1, 1:2),  arrayCenter);
%    [~, closestArray]= min(dists_vms_arrCentr, [], 2);
%    positions_within_curr_mic_array = cell2mat(array.position(closestArray));
%    distMics_CptPts = pdist2(cptPts.position(vm,1:2),  positions_within_curr_mic_array(:, 1:2));
%    [~, closestMic]= min(distMics_CptPts, [], 2);
%%    mean3 = @(x) sqrt(mean(abs(x).^2,3));
%%    totalDiffuseSTFT = cellfun(mean3, array.meanDiffuseSTFT, 'UniformOutput', false);
%
%
%    for aa = 1:array.N
%        % noise_field{aa} = my_istft(totalDiffuseSTFT{aa}, params);  % has artifacts
%
%        % using the diffuse of the closest mic
%        noise_field{aa} = array.meanDiffuse{aa}(:, closestMic);
%%        noise_field{aa} = noise_field{aa}/10;
%        noise_field_STFT{aa} = my_stft(noise_field{aa}, params);
%%        audiowrite(['output_audio/noise', num2str(aa), '.wav'],noise_field{aa},params.Fs);  % artifacts
%    end
%
%
%
%    fig = figure('Visible', 'off');
%    plot(array.arraySignal{1}(:, 1),'-k','LineWidth',1)
%    hold on;
%    plot(noise_field{1},'.r','LineWidth',1)
%    hold off;
%    xlabel('Time');
%    ylabel('Amplitude');
%    title("Complete vs NF");
%    legend('Complete', 'NF');
%    grid on;
%    saveas(fig, ['output_plots/Complete_vs_NF.png']);
%    close(fig);
%
%    distFactorA = (1 ./ dists_vms_arrCentr(vm,:).');
%    distFactorA = distFactorA ./ sum(distFactorA);
%    base_diffuse_STFT_A = zeros(params.fLen, params.tLen);
%    distFactorB = (1 ./ dists_vms_arrCentr(vm+1,:).');
%    distFactorB = distFactorB ./ sum(distFactorB);
%    base_diffuse_STFT_B = zeros(params.fLen, params.tLen);
%
%    for dd = 1:array.N
%        base_diffuse_STFT_A = base_diffuse_STFT_A + (distFactorA(dd) * noise_field_STFT{dd});
%        base_diffuse_STFT_B = base_diffuse_STFT_B + (distFactorB(dd) * noise_field_STFT{dd});
%    end
%
%    base_diffuse_A = my_istft(base_diffuse_STFT_A, params);
%    base_diffuse_B = my_istft(base_diffuse_STFT_B, params);
%    audiowrite(['output_audio/noiseA.wav'],base_diffuse_A,params.Fs);
%    audiowrite(['output_audio/noiseB.wav'],base_diffuse_B,params.Fs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%    noise_field = abs(array.arraySignal{1}(:, 1)) - abs(array.meanDerev{1}(:, 1));
%
%    fig = figure('Visible', 'off');
%    plot(array.arraySignal{1}(:, 1),'-k','LineWidth',1)
%    hold on;
%    plot(array.meanDerev{1}(:, 1),'-.b','LineWidth',1)
%    hold on;
%    plot(array.meanDiffuse{1}(:, 1),'.r','LineWidth',1)
%    hold on;
%    plot(noise_field,'.g','LineWidth',1)
%    hold off;
%    xlabel('Time');
%    ylabel('Amplitude');
%    title("Complete vs Dereverb vs Diffuse vs NF");
%    legend('Complete', 'Dereverb', 'Diffuse', 'NF');
%    grid on;
%    saveas(fig, ['output_plots/Complete_vs_Dereverb_vs_Diffuse_vs_NF.png']);
%    close(fig);
%    display(new_nmse(noise_field, array.meanDiffuse{1}(:, 1)));
