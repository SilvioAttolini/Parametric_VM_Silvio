function cptPts = place_vm(cptPts, room, source)
    % This function computes the vm locations

    cptPts.center = cell(cptPts.couplesN, 1);
    cptPts.position = zeros(cptPts.couplesN*cptPts.micN, 3);

    cptPts_R = 1; % m
    vm_couple_tilt = pi/3;

    for s = 1:source.N
        [centerCoord(:,1), centerCoord(:,2)] = pol2cart(0:2*pi/cptPts.couplesN:2*pi*(1-1/cptPts.couplesN), ...
                                                        cptPts_R);
        centerCoord(:, 3)  = room.z/2;
        cptPts.center = centerCoord + source.position{s};

        [mic_displ(:,1),mic_displ(:,2)] = pol2cart((0:2*pi/cptPts.micN:2*pi*(1-1/cptPts.micN)) + vm_couple_tilt, ...
                                                    cptPts.distance);

        % Place the vms in the environment. only change the x and y displacements
        couple = 1;
        for vm = 1:cptPts.couplesN*cptPts.micN
            if mod(vm, 2) == 1
                cptPts.position(vm, 1:2) = cptPts.center(couple, 1:2) + mic_displ(1, :);  % mic A of the couple
            else
                cptPts.position(vm, 1:2) = cptPts.center(couple, 1:2) + mic_displ(2, :); % mic B of the couple
                couple = couple+1;
            end
        end
    end

    cptPts.N = length(cptPts.position);

end
