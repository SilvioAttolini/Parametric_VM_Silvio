function plot_setup(room, source, array, cptPts)

    fprintf("Rendering setup...\n");

    fig = figure('Visible', 'off');

    % Draw room
    rectangle('Position', [0,0,room.dim(1:2)], 'LineWidth', 1);
    hold on

    % Draw sources
    sourcePos = cell2mat(source.position');
    h1 = scatter(sourcePos(:,1), sourcePos(:,2), 50, 'red', 'diamond', 'filled');
    for iSrc = 1:source.N
        [tt, rr] = ch2pol(180, source.coefficient{iSrc}', source.orientation{iSrc}(1));
        [xPatt, yPatt] = pol2cart(tt, abs(rr*0.5));
        h2 = plot(xPatt + sourcePos(iSrc,1), yPatt + sourcePos(iSrc,2), 'red', 'linewidth', 1.5);
    end

    % Draw real mics
    for aa = 1:array.N
        tmp = cell2mat(array.position(aa));
        h3 = scatter(tmp(:,1),tmp(:,2),30,'bo');
    end

    % Draw virtual mics
    h4 = scatter(cptPts.position(:,1), cptPts.position(:,2), 50, 'k', 'square', 'filled');
    for c = 1:cptPts.N
        if mod(c, 2) == 1
            x = [cptPts.position(c,1), cptPts.position(c+1,1)];
            y = [cptPts.position(c,2), cptPts.position(c+1,2)];
            h5 = plot(x, y, 'k-', 'LineWidth', 2);
        end
    end

    grid on;
    axis equal
    xlabel('x [m]')
    ylabel('y [m]')
    title('Geometric setup')
    legend([h1, h2, h3, h4, h5], ...
           {"Source", "Radiation pattern", "Real mics", "Virtual mics", "Couple"}, ...
           'Location', 'bestoutside');

    saveas(fig, 'output_plots/scene.png');
    fprintf("Setup saved as scene.png\n");

    close(fig);

end
