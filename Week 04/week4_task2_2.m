%Stabilizes the traffic sequence using point feature matching

clear all; close all;
addpath(genpath('.'))

%Results dir
directory_results =  '../Database/Week05';
if ~exist(directory_results, 'dir')
    mkdir(directory_results);
end


filename = '../Database/Week02/trafficvideo/traffic.avi';
output_file = strcat(directory_results,filesep,'traffic_stabilized.avi');

%point_feature_matching(filename,directory_results);
vidObj = stabilizationVideo2(60,160,filename,output_file);
