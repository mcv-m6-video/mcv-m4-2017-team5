function stack = video2im(filename,visualization,write_path)

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
    Height = int8(v.Height);
    Width = int8(v.Width);
    numFrames = int8(frameRate*time);

    %Creating the empty stack of images
    stack = zeros(Height,Width,3,numFrames);

    formatSpec = 'video%03d.png';
    for i = 1:numFrames
        fr = im2double(read(v,i));
        framename=sprintf(formatSpec,i);
        imwrite(fr,strcat(write_path,filesep,framename));
        if visualization
            imshow(fr);
        end
    end

end