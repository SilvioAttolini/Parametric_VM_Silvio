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

% Compute/Retrieve the microphone signals
quickload1 = true;  % avoids rir calculations
array = get_array_signal(array, source, room, params, quickload1);

% Get ground truth signals at vms
quickload2 = true;  % avoids rir calculations
cptPts = get_reference_signal(cptPts, source, room, params, quickload2);

% Compute the VM signals
quickload3 = true;  % skips source localization
quickload4 = true;  % skips array dereverberation
quickload5 = true;  % skips direct signal spherical harmonics expansion
quickload6 = true;  % skips estimation of direct signal
cptPts = parametric_virtual_miking(array, source, cptPts, params, macro, quickload3, ...
                                   quickload4, quickload5, quickload6);

%% Compute the metrics on the full signal
metrics(cptPts);
