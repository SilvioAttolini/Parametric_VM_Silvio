function couple_noise = extract_noise(array, params, cptPts, vm)

    base_diffuse_A = (cptPts.referenceComplete(:, vm) - cptPts.referenceDirect(:, vm))/10;
    base_diffuse_A = base_diffuse_A + max(base_diffuse_A)*randn(length(base_diffuse_A),1)/100;
    base_diffuse_B = (cptPts.referenceComplete(:, vm+1) - cptPts.referenceDirect(:, vm+1))/10;
    base_diffuse_B = base_diffuse_A + max(base_diffuse_B)*randn(length(base_diffuse_B),1)/100;

    fig = figure('Visible', 'off');
    plot(cptPts.referenceComplete(:, vm),'-k','LineWidth',1)
    hold on;
    plot(base_diffuse_A,'-.r','LineWidth',1)
    hold off;
    xlabel('Time');
    ylabel('Amplitude');
    title("Complete vs NF");
    legend('Complete', 'NF');
    grid on;
    saveas(fig, ['output_plots/Complete_vs_NF.png']);
    close(fig);

    couple_noise = [base_diffuse_A; base_diffuse_B];

end






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