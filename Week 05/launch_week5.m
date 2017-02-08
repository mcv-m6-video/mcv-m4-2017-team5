clear all; close all;
addpath(genpath('.'));

%Input params
% videofile = '../Database/Week02/trafficvideo/traffic.avi';%Input video
% videofile = '../Database/Week05/Road_01/Road_01_new_scale.avi';
videofile = '../Database/Week05/v2_BG_lights/backgroundlights_motion.avi';
% videofile = '../Database/Week05/v2_BG_nolights/backgroundNOlights_motion.avi';
% videofile = '../Database/Week05/v1.avi';
% videofile = '../Database/Week05/highway.avi';   
% videofile = '../Database/Week05/traffic_stabilized.avi';    

background_estimation = 'S&G';% 'S&G' or 'gaussian'
video_filename = 'v1_result.avi';%Name of the tracking video file (the result)


output_path='../Results/week5';%Directory of results
if ~exist(output_path, 'dir')
    mkdir(output_path);
end

output_videofile=strcat(output_path,filesep,video_filename);

multiObjectTracking(videofile, output_videofile, background_estimation);