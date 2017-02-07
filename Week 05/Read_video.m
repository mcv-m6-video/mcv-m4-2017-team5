addpath(genpath('.'));
%%
path_sequence = '../Videos_last_week/Road_01_new_scale.avi';
multiObjectTracking(path_sequence, 'gaussian')

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


