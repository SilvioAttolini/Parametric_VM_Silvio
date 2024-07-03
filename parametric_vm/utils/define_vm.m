function cptPts = define_vm(room, source)
    fprintf("Placing the vms...\n");

    cptPts.couplesN = 5;  % Overall number of vms
    cptPts.micN = 2;  % Number of microphone per couple
    cptPts.distance = 0.2;  % Distance between the 2 vms in each couple

    cptPts = place_vm(cptPts, room, source);

end




%th_ax = linspace(0,2*pi,5);
%
%% silvio:
%% create couples of VMs instead of isolated
%% in order to compute the cross-correlation between each pair
%th_ax = linspace(0,2*pi,50);
%x_num_vms = 10; %23; % 10; skipped
%tmp1 = th_ax(1:x_num_vms:end);
%tmp2 = tmp1+pi/40; %th_ax(2:x_num_vms:end+1);
%final_result = [];
%for i = 1:length(tmp1)
%    final_result = [final_result, tmp1(i), tmp2(i)];
%end
%th_ax = final_result;
%% :silvio
%
%th_ax = th_ax(1:end); % + deg2rad(1.5);
%distCpts = 1.0;
%[xx,yy] = pol2cart(th_ax,distCpts);
%cptPts.position = [];
%for ss = 1:source.N
%    cptPts.position = [cptPts.position;[xx(:)+source.position{ss}(1),yy(:)+source.position{ss}(2)]];
%end
%cptPts.N = size(cptPts.position,1);
%%display("Distance between source and each mic: %f\n", distCpts);
%
%% silvio:
%% distance between the mics in a pair
%%display(cptPts.position(1, :));
%%display(cptPts.position(2, :));
%vmA = cptPts.position(1, :);
%vmB = cptPts.position(2, :);
%distance = pdist([vmA; vmB], 'euclidean');
%fprintf("dist between the vms in each pair: %f\n", distance);
%%display(cptPts.position);
%% :silvio
%%pause(999);
%
%%for vm = 1:cptPts.N
%%    for ar = 1:array.N
%%        for am = 1:array.micN
%%            tmp = cell2mat(array.position(ar));
%%
%%%            display(cptPts.position(vm, 1:2));
%%%            display(tmp(am, 1:2));
%%
%%            dist_vm_arr_mic = norm(cptPts.position(vm, 1:2) - tmp(am, 1:2));
%%            fprintf("%d, %d, %d, dist: %f\n", vm, ar, am, dist_vm_arr_mic);
%%        end
%%    end
%%end