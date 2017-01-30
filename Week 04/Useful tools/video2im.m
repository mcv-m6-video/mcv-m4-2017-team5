function stack = video2im(filename,visualization)


if nargin < 1
    filename = 'traffic.avi';
    visualization = false;
end

if nargin < 2
    visualization = false; 
end

%Loading the video
v = VideoReader(filename);

%Reading the video characteristics
time = v.duration;
frameRate = v.FrameRate;
Height = v.Height;
Width = v.Width;
numFrames = frameRate*time;

%Creating the empty stack of images
stack = zeros(Height,Width,3,numFrames);



for i = 1:numFrames
    stack(:,:,:,i) = im2double(readFrame(v));
end

if visualization
    for i = 1:numFrames
        imshow(stack(:,:,:,i));
    end
end