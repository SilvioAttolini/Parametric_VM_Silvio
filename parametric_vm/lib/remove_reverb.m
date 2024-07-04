function array = remove_reverb(array, source, params, macro, quickload)

    if quickload
        fprintf("Retrieving dereverberated array data...\n");
        load("storage/array_no_rev.mat", 'array');
    else
        fprintf('Computing the dereverberation with DOA...\n')
        array = dereverbarraywithdoa(array, source, params, macro);
        save("storage/array_no_rev.mat", 'array', '-v7.3');
    end

end
