function couple_diffuse = extract_noise(array, params, cptPts, vm)

    method = "bst"; % "bst": best cases (reference)
                    % "avg": weighted average
                    % "rnd": random choice

    couple_diffuse = choose_diffuse(method, array, params, cptPts, vm);

end
