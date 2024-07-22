function weighted_diffuse = weighted_diffuse_contributions(array, params, cptPts, vm)

    % il diffuso calcolato qui rimane più basso di quello del caso di riferimento
    % perchè il diffuso di partenza è quello dei mic reali, che sono più
    % distanti dalla sorgente rispetto ai vm
    % cosa che non dovrebbe essere vera perchè assumiamo che il rumore sia
    % omogeneo e isotropico
    % Quello che dovrebbe cambiare è il rapporto tra il segnale diretto e la
    % componente diffusa: in prossimità della sorgente (quindi nei vm) il DRR dovrebbe
    % mostrare dir>>diff, mentre in lontantanza (dove stanno i mics) dovrebbe
    % risultare diff>=dir

    positions = cell2mat(array.position);
    dists_realMics_vm = pdist2(cptPts.position(vm,1:2),  positions(:, 1:2));
    dists_realMics_vm = dists_realMics_vm.^2;
%    display(dists_realMics_vm);

    % Calculate weights (inverse of distances) and Normalize weights to sum to 1
    weights = 1 ./ dists_realMics_vm;
    weights = weights / sum(weights);
%    display(weights);

    amplifiers = zeros(size(weights));

    tLen = length(array.meanDiffuse{1}(:,1));
%    diffuses_before_travel = zeros(tLen, array.N*array.micN);
    diffuses_after_travel = zeros(tLen, array.N*array.micN);
    mic = 1;
    for aa = 1:array.N
        for mm = 1:array.micN
            weighted_diff = array.meanDiffuse{aa}(:,mm) * weights(mic);
            % the amplifier accounts for the fact that real mics are further away than vms,
            % therefore their diffuse component must be amplified to reach the expected
            % amplitude
            amplifiers(mic) = max(abs(cptPts.estimateDirect(:, vm))) / max(abs(array.arrayDirectSignal{aa}(:,mm)));
            diffuses_after_travel(:, mic) = weighted_diff;  % * amplifier;
            % use the ratio between the distances from the source as amplifier? (loses info on source direct)


%            fft_diff = fft(array.meanDiffuse{aa}(:,mm));
%            diffuses_after_travel(:, mic) = ifft(fft_diff*weights(mic));

            mic = mic + 1;
        end
    end

    weighted_diffuse = sum(diffuses_after_travel, 2);

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

%%    amplifiers = amplifiers / sum(amplifiers);
%%    contributions = amplifiers * 100;
%    filename = sprintf('output_plots/ampllifiers_to_vm_Diffuse_%d.png', vm);
%    % Plot contributions
%    fig = figure('Visible', 'off');
%    bar(amplifiers);
%    xlabel('Microphone');
%    ylabel('ampl');
%    title('Amplifiers');
%    grid on;
%    saveas(fig, filename);
%    close(fig);
end
