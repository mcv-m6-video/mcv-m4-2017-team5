clear all; close all;
addpath(genpath('.'));

background_estimation = 'S&G'; % 'S&G' or 'gaussian' or 'GMM'
Sequence = 'Road01';

switch Sequence %Input video
    case 'Traffic'
        videofile='../Database/Week02/trafficvideo/traffic.avi';
        MBA=2000;
    case 'Traffic_stabilized'
        videofile='../Database/Week02/trafficvideo/traffic_stabilized.avi';
    case 'Highway'
        videofile = '../Database/Week02/highwayvideo/highway.avi';
        MBA = 2000;
    case 'Road01'
        videofile = '../Database/Week05/Road_01/Road_01_new_scale.avi';
        MBA = 1000;
end


output_path = '../Results/week5';%Directory of results
video_filename = strcat(Sequence,'_',background_estimation,'.avi');%Name of the tracking video file

if ~exist(output_path, 'dir')
    mkdir(output_path);
end

output_videofile=strcat(output_path,filesep,video_filename);

if strcmp(background_estimation,'GMM')
     Tracking_GMM(videofile,output_videofile,Sequence)
elseif strcmp(background_estimation,'meanShift')
     matlab_mean_shift_avi(output_videofile,Sequence)
else
     multiObjectTracking(videofile,output_videofile,Sequence, background_estimation,MBA);
end

