%Stabilizes the traffic sequence using block matching

clear all; close all;
addpath(genpath('.'))

%Whether to stabilize GT or not
stabilize_GT = true;

%Sequence dir
directory_sequence = '../Database/Week02/traffic/input';
directory_sequenceGT = '../Database/Week02/traffic/groundtruth';

%Results dir
directory_results = '../Results/week4/stabilized_traffic';
if ~exist(directory_results, 'dir')
    mkdir(directory_results);
end

if stabilize_GT
    directory_resultsGT = '../Results/week4/stabilized_trafficGT';
    if ~exist(directory_resultsGT, 'dir')
       mkdir(directory_resultsGT);
    end
    
    disp('Stabilizing video...');
    stabilize_videoGT(directory_sequence,directory_sequenceGT,directory_results,directory_resultsGT);
    directory_sequenceGT = directory_resultsGT;
else
    disp('Stabilizing video...');
    stabilize_video(directory_sequence,directory_results);
end

disp('Performing foreground detection...');
performForegroundDetection(directory_results,'../Results/week4/foreground/traffic',directory_sequenceGT,'../Database/Week02/traffic/input')