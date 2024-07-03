function room = define_room()
    fprintf("Building the room...\n");

    % Room settings
    room.x = 5;                             % x length
    room.y = 4;                             % y length
    room.z = 3;                             % z length
    room.dim = [room.x, room.y, room.z];    % room dimensions
    room.volume = room.x * room.y * room.z;
    room.surface = room.x*room.z*2 + room.y*room.z*2 + room.x*room.y*2;
    room.T60 = 0.4;                         % room T60, in seconds
    room.reflectionOrder = 20;
    room.diffuseTime = [];                  % Consider also the early reflections

end
