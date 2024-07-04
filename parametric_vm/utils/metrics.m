function metrics(cptPts)

    fprintf('Computing the signal to diffuse ratio...\n')

    powerDirect = sum(cptPts.referenceDirect.^2, 1);
    powerDirectEstimate = sum(cptPts.estimateDirect.^2, 1);

    powerDiffuse = sum((cptPts.referenceComplete - cptPts.referenceDirect).^2,1) ;
    powerDiffuseEstimate = sum((cptPts.estimateComplete - cptPts.estimateDirect).^2,1);

    signalDiffuseRatio = powerDirect ./ powerDiffuse;
    signalDiffuseRatioEstimate = powerDirectEstimate ./ powerDiffuseEstimate;

    fig = figure('Visible', 'off');
    plot(db(signalDiffuseRatio))
    hold on;
    plot(db(signalDiffuseRatioEstimate))
    hold off;
    ylim([-60, 20]);
    xlabel('VM index');
    ylabel('[dB]');
    legend('GT', 'Estimate')
    title('DRR')
    grid on;
    saveas(fig, ['output_plots/Metrics.png']);
    close(fig);

end
