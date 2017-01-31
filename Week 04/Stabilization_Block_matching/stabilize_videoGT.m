function stabilize_videoGT(directory_sequence,directory_sequenceGT,directory_results,directory_resultsGT)
%Performs video stabilization using block matching
%   directory_sequence: path where the frames files are
%   directory_results: path where the compensated sequence is saved

    frame_files = dir([directory_sequence '/*.jpg']);
    frame_filesGT = dir([directory_sequenceGT '/*.png']);

    if isempty(frame_files)
        frame_files = dir([directory_sequence '/*.png']);
    end
    
    if isempty(frame_filesGT)
        frame_filesGT = dir([directory_sequenceGT '/*.png']);
    end
    
    %For gif
    gif_subplots=cell(1,2);
    titles={'Original','Stabilized'};
    
    %Frame 1 
    compensated_frame = rgb2gray(im2double(imread(strcat(directory_sequence, filesep, frame_files(1).name))));
    compensated_frameGT = im2double(imread(strcat(directory_sequenceGT, filesep, frame_filesGT(1).name)));
    imwrite(compensated_frameGT, [directory_resultsGT,filesep,frame_files(1).name]);
    for i = 2:length(frame_files)-1
        frame2 = rgb2gray(im2double(imread(strcat(directory_sequence, filesep, frame_files(i).name))));
        frameGT = im2double(imread(strcat(directory_sequenceGT, filesep, frame_filesGT(i).name)));

        %Gif
        gif_subplots{1}=frame2;
        gif_subplots{2}=compensated_frame;
        gif_horizontal_plots(directory_results,'BMstab.gif',gif_subplots,titles,i-1);

        %Compute optical flow
        flow_estimation = compute_optical_flow(compensated_frame, frame2);
        %Compensate second frame
        compensated_frame = get_compensated_image(flow_estimation, frame2);
        compensated_frameGT = get_compensated_image(flow_estimation,frameGT);
        imwrite(compensated_frame, [directory_results,filesep,frame_files(i).name]);
        imwrite(compensated_frameGT, [directory_resultsGT,filesep,frame_files(i).name]);

    end
end