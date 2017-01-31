function stabilize_video(directory_sequence,directory_results)
%Performs video stabilization using block matching
%   directory_sequence: path where the frames files are
%   directory_results: path where the compensated sequence is saved

    frame_files = dir([directory_sequence '/*.jpg']);
    if isempty(frame_files)
        frame_files = dir([directory_sequence '/*.png']);
    end

    %Frame 1 
    compensated_frame = rgb2gray(im2double(imread(strcat(directory_sequence, filesep, frame_files(1).name))));
    for i = 2:length(frame_files)-1
        frame2 = rgb2gray(im2double(imread(strcat(directory_sequence, filesep, frame_files(i).name))));

        %Gif
        subplot(121);
        imshow(frame2);
        title('Original')
        subplot(122),
        imshow(compensated_frame);
        title('Compensated')
        frame = getframe(gcf);
        im = frame2im(frame);
        [imind, cm] = rgb2ind(im, 256);
        if i == 2
            imwrite(imind,cm,[directory_results,filesep,'BMstab.gif'],'gif','DelayTime',0,'Loopcount',inf);
        else
            imwrite(imind,cm,[directory_results,filesep,'BMstab.gif'],'gif','DelayTime',0,'WriteMode','append');
        end

        %Compute optical flow
        flow_estimation = compute_optical_flow(compensated_frame, frame2);
        %Compensate second frame
        compensated_frame = get_compensated_image(flow_estimation, frame2);

        imwrite(compensated_frame, [directory_results,filesep,frame_files(i).name]);
    end
end