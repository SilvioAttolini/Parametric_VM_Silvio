function [mic_sig, mic_STFT] = get_mic_sig(params, pos, room, source, reverb, iSrc)

    tLen = params.tLen;
    sourcePos = cell2mat(source.position');

    if reverb
        [~, impResp] = rir(params.c, params.Fs, sourcePos(iSrc,:), pos, room.dim, ...
                           room.T60, params.Nfft, source.type{iSrc}, room.reflectionOrder, 3, ...
                           source.orientation{iSrc}, false, room.diffuseTime);
    else
        [~, impResp] = rir(params.c, params.Fs, sourcePos(iSrc,:), pos, room.dim, ...
                           0, params.Nfft, source.type{iSrc}, 0, 3, source.orientation{iSrc}, false);
    end

    impRespFrame = repmat(impResp.', 1, tLen);
    mic_STFT = source.sourceSTFT{iSrc} .* impRespFrame;
    mic_sig = my_istft(mic_STFT, params);

end

%    tic;
%    fprintf('Elapsed time: %.3f seconds\n', toc);

    % if we add the noise at the source signal, here we have
    % to highpass the rir

%    if reverb
    %    fig = figure('Visible', 'off');
    %    plot(arraySignal{aa}(:, mm),'-k','LineWidth',1.5)
    %    xlabel('Time [s]');
    %    ylabel('Sig');
    %    title("sig");
    %    legend('sig');
    %    grid on;
    %    saveas(fig, ['output_plots/sig', num2str(aa), num2str(mm), '.png']);
    %    close(fig);
    %    audiowrite(['output_audio/rir', num2str(aa), num2str(mm), '.wav'], arraySignal{aa}(:, mm),params.Fs);
%    end





% old:
    %    tic;
    %    [~, impResp] = rir(params.c, params.Fs, sourcePos(iSrc,:), arrayPos(mm,:), room.dim, ...
    %                       room.T60, params.Nfft, source.type{iSrc}, room.reflectionOrder, 3, ...
    %                       source.orientation{iSrc}, false, room.diffuseTime);
    %    fprintf('Elapsed time: %.6f seconds\n', toc);
    %
    %    impRespFrame = repmat(impResp.', 1, tLen);
    %    current = source.sourceSTFT{iSrc} .* impRespFrame;
    %    arraySTFT{aa}(:,:,mm) = arraySTFT{aa}(:,:,mm) + current;
    %    rir_time = my_istft(arraySTFT{aa}(:,:,mm), params);


%    display(new_nmse(rir_time, new_rir_time));
    %
    %    % rir vs new_rir
    %    fig = figure('Visible', 'off');
    %    plot(rir_time,'-k','LineWidth',1.5)
    %    xlabel('Time [s]');
    %    ylabel('Rir');
    %    title("rir");
    %    legend('rir');
    %    grid on;
    %    saveas(fig, ['output_plots/rir.png']);
    %    close(fig);
    %
    %    fig = figure('Visible', 'off');
    %    plot(new_rir_time,'-k','LineWidth',1.5)
    %    xlabel('Time [s]');
    %    ylabel('Rir');
    %    title("new_rir");
    %    legend('new_rir');
    %    grid on;
    %    saveas(fig, ['output_plots/new_rir.png']);
    %    close(fig);
    %
    %    display("ok");
    %    pause(99);
