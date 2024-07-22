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