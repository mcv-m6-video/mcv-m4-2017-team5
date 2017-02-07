clear all; close all;
addpath(genpath('.'));

videofile='../Database/Week02/trafficvideo/traffic.avi';%Input video

output_path='../Results/week5';%Directory of results
video_filename='trafficresult.avi';%Name of the tracking video file

if ~exist(output_path, 'dir')
    mkdir(output_path);
end


output_videofile=strcat(output_path,filesep,video_filename);

multiObjectTracking(videofile,output_videofile);