function array = define_array(room)
    fprintf("Placing the arrays...\n");

    array.N = 9;  % Number of arrays
    array.micN = 4;  % Number of microphone per array
    array.radius = 0.04;  % Radius of the array

    array = place_array(array, room);

end
