addpath(genpath('.'));
%%
videofile = '../Videos_last_week/Road_01_new_scale.avi';

background_estimation = 'gaussian';% 'S&G' or 'gaussian'
video_filename = 'Road_01_results.avi';%Name of the tracking video file (the result)


output_path = '../Results/week5'; %Directory of results
if ~exist(output_path, 'dir')
    mkdir(output_path);
end

output_videofile = strcat(output_path,filesep,video_filename);

multiObjectTracking(videofile, output_videofile, background_estimation);
%%
% write_path = '../Results/week5/Road_01_images';
% if ~exist(write_path, 'dir')
%     mkdir(write_path);
% end
% visualization = 0;
% resize_scale = 1;
% stack = video2im(path_sequence, write_path,resize_scale,visualization);
%%

% path_write = '../Videos_last_week/Road_01_for_train';
% path_read = '../Videos_last_week/Road_01_new_scale.avi';
% keep_frames = [1630 1710];
% crop_video( path_read, path_write, keep_frames)

%%
% path_read = '../Videos_last_week/Road_01_original.mp4';
% path_write = '../Videos_last_week/Road_01_new_scale';
% resize_scale = 0.2;
% resize_video( path_read, path_write, resize_scale)


