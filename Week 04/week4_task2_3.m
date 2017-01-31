%Generates the frames files from the video file (assumed to be located in Week 04)

clear all; close all;
addpath(genpath('.'))


filename = 'customvideo.mp4';

%Where the frames folder is placed
directory_sequence = '../Results/week4/custom_video';
if ~exist(directory_sequence, 'dir')
    mkdir(directory_sequence);
    
    vid=video2im(filename,directory_sequence,0.25,false);
end

%%
%Block matching stabilization

%Results dir
directory_results = '../Results/week4/stabilized_custom_video';
if ~exist(directory_results, 'dir')
    mkdir(directory_results);
end

stabilize_video(directory_sequence,directory_results);