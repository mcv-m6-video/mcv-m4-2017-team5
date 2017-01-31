function stack = video2im(filename,write_path,resize_scale,visualization)

    if nargin < 1
        filename = 'traffic.avi';
    end

    if nargin < 4
        visualization = false; 
    end

    %Loading the video
    v = VideoReader(filename);

    %Reading the video characteristics
    time = v.duration;
    frameRate = v.FrameRate;
    Height = int8(v.Height);
    Width = int8(v.Width);
    numFrames = int8(frameRate*time);

    %Creating the empty stack of images
    stack = zeros(Height,Width,3,numFrames);

    formatSpec = 'video%03d.png';
    for i = 1:numFrames
        fr = im2double(read(v,i));
        fr = imresize(fr, resize_scale);
        framename=sprintf(formatSpec,i);
        imwrite(fr,strcat(write_path,filesep,framename));
        if visualization
            imshow(fr);
        end
    end

end