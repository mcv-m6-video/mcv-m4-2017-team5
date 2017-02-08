clear all; close all;
addpath(genpath('.'));

background_estimation = 'GMM'; % 'S&G' or 'gaussian' or 'GMM'
Sequence = 'Traffic';

switch Sequence %Input video
    case 'Traffic'
        videofile='../Database/Week02/trafficvideo/traffic.avi';
    case 'Traffic_stabilized'
        videofile='../Database/Week02/trafficvideo/traffic_stabilized.avi';
    case 'Highway'
        videofile='/Users/lidiatalavera/mcv-m4-2017-team5/Database/Week02/highwayvideo/highway.avi';
    case 'ownVideo'
        videofile='/Users/lidiatalavera/mcv-m4-2017-team5/Database/Week02/ownVideo/ownVideo.avi';
end

output_path = '../Results/week5';%Directory of results
video_filename = strcat(Sequence,'_',background_estimation,'.avi');%Name of the tracking video file

if ~exist(output_path, 'dir')
    mkdir(output_path);
end

output_videofile=strcat(output_path,filesep,video_filename);

if strcmp(background_estimation,GMM)
    Tracking_GMM(videofile,output_videofile,Sequence)
else
    multiObjectTrackingT(videofile,output_videofile,Sequence, background_estimation);
end

