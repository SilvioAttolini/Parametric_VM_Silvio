clc
clear
close all

%% Setup
fprintf('Setting up...\n');
addpath(genpath('audio'));
addpath(genpath('fourier'));
addpath(genpath('lib'));
addpath(genpath('output_plots'));
addpath(genpath('storage'));
addpath(genpath('utils'));
addpath(genpath('harmonicY'));

% quickload avoids rir calculations
quickload1 = true;
quickload2 = false;

% Define useful structures
macro = define_macro();
params = define_params();
room = define_room();
source = define_source(room);

%% Load the source signals and define their location
[params, source] = get_source_signal(params, source);

%% Place the real mic arrays
array = define_array(room);

%% Place the virtual mics
cptPts = define_vm(room, source);

%% Plot the setup
if macro.PRINT_SETUP == true
    plot_setup(room, source, array, cptPts);
end

%% Compute/Retrieve the microphone signals
array = get_array_signal(array, source, room, params, quickload1);

% remember that this order is swapped!
cptPts = get_reference_signal(cptPts, source, room, params, quickload2);
display(cptPts);
pause(999);

for mm = 1:cptPts.N
    directReference(:,mm) = istft(directReferenceSTFT(:,:,mm), params.analysisWin,...
        params.synthesisWin, params.hop, params.Nfft, params.Fs);
    completeReference(:,mm) = istft(completeReferenceSTFT(:,:,mm), params.analysisWin,...
        params.synthesisWin, params.hop, params.Nfft, params.Fs);
        % these are the ground truth RIRs in time, for the VMs
end

%save('audio_out/vm_completeReference.mat', 'completeReference', '-v7.3'); % time
%display("ref");
%quit();

% Compute the VM signals!
[completeEstimate, directEstimate] = parametricvirtualmiking(array, source, cptPts, [], params, macro);


%% Compute the metrics on the full signal
fprintf('Compute the signal to diffuse ratio...\n')


powerDirect = sum(directReference.^2, 1);
powerDirectEstimate = sum(directEstimate.^2, 1);

powerDiffuse = sum((completeReference - directReference).^2,1) ;
powerDiffuseEstimate = sum((completeEstimate - directEstimate).^2,1);

signalDiffuseRatio = powerDirect ./ powerDiffuse;
signalDiffuseRatioEstimate = powerDirectEstimate ./ powerDiffuseEstimate;

figure()
plot(db(signalDiffuseRatio)), hold on
plot(db(signalDiffuseRatioEstimate))
ylim([-60, 20]), xlabel('VM index'), ylabel('[dB]');
legend('GT', 'Estimate')
title('DRR')


