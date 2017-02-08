clear all; close all;
addpath(genpath('.'));

<<<<<<< HEAD
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
=======
%Input params
% videofile = '../Database/Week02/trafficvideo/traffic.avi';%Input video
% videofile = '../Database/Week05/Road_01/Road_01_new_scale.avi';
% videofile = '../Database/Week05/v2_BG_lights/backgroundlights_motion.avi';
% videofile = '../Database/Week05/v2_BG_nolights/backgroundNOlights_motion.avi';
% videofile = '../Database/Week05/v1.avi';
% videofile = '../Database/Week05/highway.avi';   
% videofile = '../Database/Week05/traffic_stabilized.avi';  
videofile = '../Database/Week05/v4/v4_motion.avi';

background_estimation = 'S&G';% 'S&G' or 'gaussian'
video_filename = 'v1_result.avi';%Name of the tracking video file (the result)

>>>>>>> 6af203d1b87dc796e8ff591740d17402c263625c

output_path='../Results/week5';%Directory of results
if ~exist(output_path, 'dir')
    mkdir(output_path);
end

output_videofile=strcat(output_path,filesep,video_filename);

<<<<<<< HEAD
if strcmp(background_estimation,GMM)
    Tracking_GMM(videofile,output_videofile,Sequence)
else
    multiObjectTrackingT(videofile,output_videofile,Sequence, background_estimation);
end

=======
multiObjectTracking(videofile, output_videofile, background_estimation);
>>>>>>> 6af203d1b87dc796e8ff591740d17402c263625c
