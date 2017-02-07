clear all; close all;
addpath(genpath('.'));

%Input params
videofile = '../Database/Week02/trafficvideo/traffic.avi';%Input video
background_estimation = 'S&G';% 'S&G' or 'gaussian'
video_filename='trafficresult.avi';%Name of the tracking video file


output_path='../Results/week5';%Directory of results
if ~exist(output_path, 'dir')
    mkdir(output_path);
end

output_videofile=strcat(output_path,filesep,video_filename);

multiObjectTracking(videofile, output_videofile, background_estimation);