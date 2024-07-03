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
quickload1 = true;  % quickload avoids rir calculations
array = get_array_signal(array, source, room, params, quickload1);

% remember that this order is swapped!
quickload2 = true;  % quickload avoids rir calculations
cptPts = get_reference_signal(cptPts, source, room, params, quickload2);

% Compute the VM signals!
cptPts = parametricvirtualmiking(array, source, cptPts, [], params, macro);

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


