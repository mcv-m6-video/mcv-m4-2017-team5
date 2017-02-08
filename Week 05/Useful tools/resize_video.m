function [  ] = resize_video( path_read, path_write, resize_scale)

%Loading the video
v = VideoReader(path_read);
writerObj = VideoWriter(path_write);


%Reading the video characteristics
time = v.duration;
frameRate = v.FrameRate;
writerObj.FrameRate = v.FrameRate;
numFrames = uint32(frameRate*time);

%Creating the empty stack of images
% stack = zeros(Height,Width,3,numFrames);

open(writerObj);

for i = 1:numFrames
    
%     fr = im2double(read(v,i));
    fr = read(v,i);
    fr = imresize(fr, resize_scale);
    
    
    writeVideo(writerObj, fr);
end
close(writerObj);


% N=24;
% 
% writerObj = VideoWriter(path_write);
% writerObj.FrameRate = N;
% open(writerObj);
% figure;
% for i=1:numel(files) %number of images to be read
%      
%      
%      input = imread(files(i).name);
% 
%      % Write frame now
%      writeVideo(writerObj, input);
% end


end

