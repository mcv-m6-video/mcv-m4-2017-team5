%Stabilizes the traffic and custom sequences

clear all; close all;
addpath(genpath('.'))

%Sequence dir
directory_sequence = '../Database/Week02/traffic/input';

%Results dir
directory_results = '../Results/week4/stabilized_traffic';
if ~exist(directory_results, 'dir')
    mkdir(directory_results);
end

stabilize_video(directory_sequence,directory_results);
