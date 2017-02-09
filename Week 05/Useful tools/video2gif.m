function video2gif(filename,write_path,gif_name,resize_scale,visualization)

    if nargin < 1
        filename = 'traffic.avi';
    end

    if nargin < 5
        visualization = false; 
    end

    %Loading the video
    v = VideoReader(filename);

    %Reading the video characteristics
    time = v.duration;
    frameRate = v.FrameRate;
    Height = uint32(v.Height);
    Width = uint32(v.Width);
    numFrames = uint32(frameRate*time);

    for i = 1:numFrames
        fr = im2double(read(v,i));
        gif_horizontal_plots(write_path,gif_name,{fr},{''},i);
        %fr = imresize(fr, resize_scale);
        if visualization
            imshow(fr);
        end
    end

end