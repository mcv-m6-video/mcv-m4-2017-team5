%Stabilizes the traffic sequence using block matching

clear all; close all;
addpath(genpath('.'))

%Sequence dir
directory_sequence = '../Database/Week02/traffic/input';

%Results dir
directory_results = '../Results/week4/stabilized_traffic';
if ~exist(directory_results, 'dir')
    mkdir(directory_results);
end

disp('Stabilizing video...');
stabilize_video(directory_sequence,directory_results);

disp('Performing foreground detection...');
performForegroundDetection(directory_results,'../Results/week4/foreground/traffic','../Database/Week02/traffic/groundtruth')