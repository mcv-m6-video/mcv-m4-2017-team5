function stabilize_video(directory_sequence,directory_results)
%Performs video stabilization using block matching
%   directory_sequence: path where the frames files are
%   directory_results: path where the compensated sequence is saved

    frame_files = dir([directory_sequence '/*.jpg']);
    if isempty(frame_files)
        frame_files = dir([directory_sequence '/*.png']);
    end
    
    %For gif
    gif_subplots=cell(1,2);
    titles={'Original','Stabilized'};
    
    %Frame 1 
    compensated_frame = im2double(imread(strcat(directory_sequence, filesep, frame_files(1).name)));
    imwrite(compensated_frame, [directory_results,filesep,frame_files(1).name]);
    for i = 2:length(frame_files)-1
        frame2color = im2double(imread(strcat(directory_sequence, filesep, frame_files(i).name)));
        frame2 = rgb2gray(frame2color);
        compensated_frame_gray = rgb2gray(compensated_frame);
        
        %Gif
        gif_subplots{1}=frame2;
        gif_subplots{2}=compensated_frame;
        gif_horizontal_plots(directory_results,'BMstab.gif',gif_subplots,titles,i-1);

        %Compute optical flow
        flow_estimation = compute_optical_flow(compensated_frame_gray, frame2);
        %Compensate second frame
        compensated_frame = get_compensated_image(flow_estimation, frame2color);

        imwrite(compensated_frame, [directory_results,filesep,frame_files(i).name]);
    end
    imwrite(rgb2gray(im2double(imread(strcat(directory_sequence, filesep, frame_files(i+1).name)))), [directory_results,filesep,frame_files(i+1).name]);%Last frame
end