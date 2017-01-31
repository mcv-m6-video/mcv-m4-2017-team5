%Stabilizes the traffic sequence using point feature matching

clear all; close all;
addpath(genpath('.'))

%Results dir
directory_results = '../Results/week4/stabilized_traffic';
if ~exist(directory_results, 'dir')
    mkdir(directory_results);
end


filename = '../Database/Week02/trafficvideo/traffic.avi';

%point_feature_matching(filename,directory_results);
vidObj = stabilizationVideo2(60,160);
