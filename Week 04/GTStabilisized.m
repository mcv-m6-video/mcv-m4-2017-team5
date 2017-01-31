%Stabilizes the traffic sequence using block matching

clear all; close all;
addpath(genpath('.'))

%Sequence dir
directory_sequence = '../Database/Week02/traffic/input';
directory_sequenceGT = '../Database/Week02/traffic/groundtruth';

%Results dir
directory_results = '../Results/week4/stabilized_traffic';
directory_resultsGT = '../Results/week4/stabilized_trafficGT';
if ~exist(directory_results, 'dir')
    mkdir(directory_results);
end

if ~exist(directory_resultsGT, 'dir')
    mkdir(directory_resultsGT);
end

stabilize_videoGT(directory_sequence,directory_sequenceGT,directory_results,directory_resultsGT);
