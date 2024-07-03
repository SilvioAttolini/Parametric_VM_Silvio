function source = define_source(room)
    fprintf("Placing the source...\n");

    % Source settings
    source.N = 1; % 2; % prova 1 per il paper
    source.signalLength = 5;  % Signal length in [s]
    source.filePath = './audio';

    source.position{1} = [1.75, 2, (room.z/2)];
    source.orientation{1} = [pi/4 0];  % Source looking angle
    source.type{1} = 'c'; % Source directivity
    source.coefficient{1} = 0.5; % if type = "c", 0 otherwise

    if source.N == 2
        source.position{2} = [3.25, 2.75 (room.z/2)];
        source.orientation{2} = [-pi/2 0];
        source.type{2} = 'c';
        source.coefficient{2} = 0.5;
    end

end
