function plot_diff_diffuses(base_diffuse_A, base_diffuse_B, cptPts, params, vm, method)

    diff = abs(using_time) - abs(using_stft);

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


%    display(params);
%
%    tt = linspace(0, params.tLen, length(base_diffuse_A));

    fig = figure('Visible', 'off');
    subplot(2,1,1);
    plot(cptPts.referenceComplete(:, vm),'-k','LineWidth',1)
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
    plot(cptPts.referenceComplete(:, vm+1),'-k','LineWidth',1)
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