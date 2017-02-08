clear all; close all;
addpath(genpath('.'));

background_estimation = 'meanShift'; % 'S&G' or 'gaussian' or 'GMM' or' meanShift'
Sequence = 'Traffic'; % 'Traffic' or 'Highway' or 'ownVideo'

switch Sequence %Input video
    case 'Traffic'
        videofile = '../Database/Week02/trafficvideo/traffic.avi';
        MBA=2000;
    case 'Highway'
        videofile = '../Database/Week02/highwayvideo/highway.avi';
        MBA=2000;
    case 'ownVideo'
        videofile = '../Database/Week02/ownVideo/ownVideo.avi';
        MBA=1000;
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

