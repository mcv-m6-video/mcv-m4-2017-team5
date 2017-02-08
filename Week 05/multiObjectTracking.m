function multiObjectTracking(file_video,output_videofile,Sequence, background_estimation,MBA)


% Create System objects used for reading video, detecting moving objects,
% and displaying the results.
%Changes from Roque to Matlab Script:
%       -Morphological operations
%               Traffic:
%                 mask = imfill(mask,4,'holes');
%                 mask = bwareaopen(mask,80,4);
%                 mask = imopen(mask, strel('line',30,45));
%                 mask = imclose(mask,strel('diamond',20));
%
%               Highway:
%                 mask = imfill(mask,'holes');
%                 mask = bwareaopen(mask,30,4);
%                 mask = imclose(mask,strel('diamond',6));
%                 mask = imopen(mask,strel('diamond',2));
%                 mask = imfill(mask,'holes');
%
%               Onofre (road 01):
%                   mask = imfill(mask, 'holes');
%                   mask = imopen(mask, strel('rectangle', [7,7]));
%                   mask = imfill(mask, 'holes');
%
%       -InvisibleForTooLong = 5 (so cars are distinguished)
%       -Adding speed (required for our task)-> Using obj.OpticalFlow

if strcmp(background_estimation, 'gaussian')
    final_mu_model = 0;
    final_sigma_model = 0;
end

obj = setupSystemObjects(file_video, background_estimation);

[tracks, speed_tracks] = initializeTracks(); % Create an empty array of tracks.
maximum_speed = 60;
nextId = 1; % ID of the next track
num_frames = 0;
v = VideoReader(file_video);
frameRate_video = v.FrameRate;
clear v
%Params
params.a0=0; % Keep it at 0 please
params.b0=240-100;
params.a1=0; % Keep it at 0 please
params.b1=220;

params.pixXframe2kmXh_highway = 15.0;
params.pixXframe2kmXh_traffic = 7.0;
params.pixXframe2kmXh_ownVideo = 10.0;

% Initialize videowriter
frame_rate=24;
writerObj = VideoWriter(output_videofile);
writerObj.FrameRate = frame_rate;
open(writerObj);

% Detect moving objects, and track them across video frames.
while ~isDone(obj.reader)
    frame = readFrame();
    num_frames = num_frames + 1;
    switch background_estimation
        case 'S&G'
            [centroids, bboxes, mask] = detectObjects(frame);
            
        case 'gaussian'
            [centroids, bboxes, mask] = detectObjects_recursive_gaussian(frame);
            
    end
    predictNewLocationsOfTracks();
    [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment();
    
    updateAssignedTracks();
    updateUnassignedTracks();
    deleteLostTracks();
    createNewTracks();
    updateSpeeds();
    displayTrackingResults();
    
    saveTrackingResults(writerObj);
end

% Close videowriter
close(writerObj);

    function obj = setupSystemObjects(file_video, background_estimation)
        % Initialize Video I/O
        % Create objects for reading a video from a file, drawing the tracked
        % objects in each frame, and playing the video.
        
        % Create a video file reader.
        obj.reader = vision.VideoFileReader(file_video);
        
        % Create two video players, one to display the video,
        % and one to display the foreground mask.
        obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
        obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
        
        % Create System objects for foreground detection and blob analysis
        
        % The foreground detector is used to segment moving objects from
        % the background. It outputs a binary mask, where the pixel value
        % of 1 corresponds to the foreground and the value of 0 corresponds
        % to the background.
        switch  background_estimation
            case 'S&G'
                obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
                    'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);
            case 'gaussian'
                train_background();
        end
        
        % Connected groups of foreground pixels are likely to correspond to moving
        % objects.  The blob analysis System object is used to find such groups
        % (called 'blobs' or 'connected components'), and compute their
        % characteristics, such as area, centroid, and the bounding box.
        
        obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', MBA); %Roque had 400
 end


    function [] = train_background()
        switch Sequence
            case 'Road01'
                filename = '../Database/Week05/Road_01/Road_01_for_train.avi';
            case '../Database/Week05/v2_BG_lights/backgroundlights_motion.avi'
                filename = '../Database/Week05/v2_BG_lights/backgroundlights_train.avi';
            case '../Database/Week05/v2_BG_nolights/backgroundNOlights_motion.avi'
                filename = '../Database/Week05/v2_BG_nolights/backgroundNOlights_train.avi';
            case '../Database/Week05/v1.avi'
                error('This does not work')
            case 'Highway'
                filename = '../Database/Week05/highway.avi';
            case 'Traffic'
                filename = '../Database/Week05/traffic.avi';
            case 'Traffic_stabilized'
                filename = '../Database/Week05/traffic_stabilized.avi';
        end
        %         v = VideoReader(file_video);
        v = VideoReader(filename);
        %Reading the video characteristics
        time = v.duration;
        frameRate = v.FrameRate;
        Height = uint32(v.Height);
        Width = uint32(v.Width);
        
        if strcmp(Sequence,'Highway') || strcmp(Sequence,'Traffic')
            numFrames = uint32(frameRate*time*0.5);
        else
            numFrames = uint32(frameRate*time);
        end
        
        final_mu_model = zeros(Height, Width, 3);
        final_sigma_model = zeros(Height, Width, 3);
        full_images_train = zeros(Height, Width, 3, numFrames);
        
        for i = 1:numFrames
            full_images_train(:, :, :, i) = im2double(read(v,i));
        end
        
        for channel = 1:3
            images_train = shiftdim(full_images_train(:, :, channel, :));
            final_mu_model(:, :, channel) = mean(images_train, 4);
            final_sigma_model(:, :, channel) = std(images_train, 1, 4);
        end
    end


    function [tracks, speed_tracks] = initializeTracks()
        % create an empty array of tracks
        tracks = struct(...
            'id', {}, ...
            'bbox', {}, ...
            'kalmanFilter', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {});
        speed_tracks = struct(...
            'status', {}, ...
            'centroid', {}, ...
            'frame_count', {}, ...
            'displacement', {}, ...
            'speed', {});
    end
    function frame = readFrame()
        frame = obj.reader.step();
    end

    function [centroids, bboxes, mask] = detectObjects_recursive_gaussian(frame)
        alpha = 0.15;
        rho = 0.1;
        % Detect foreground.
        
        mask = ones(size(frame, 1), size(frame, 2));
        for channel = 1:3
            im = frame(:, :, channel);
            mu = final_mu_model(:, :, channel);
            sigma = final_sigma_model(:, :, channel);
            
            % Determine if a pixel is background or foreground
            segmentation = abs(im - mu) >= alpha*(2 + sigma);
            
            mask = mask.*segmentation;
            %Update background model with pixels labeled as background
            mu = (1 - segmentation).*(rho*im + (1 - rho)*mu) + segmentation.*mu;
            sigma = sqrt((1 - segmentation).*(rho.*(im - mu).^2 + (1 - rho).*sigma.^2) + segmentation.*sigma.^2);
            
            final_mu_model(:, :, channel) = mu;
            final_sigma_model(:, :, channel) = sigma;
        end
        mask = logical(mask);
        mask = morphologicalOperations(Sequence,mask);
        
        
        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
    end

    function [centroids, bboxes, mask] = detectObjects(frame)
        
        % Detect foreground.
        mask = obj.detector.step(frame);
        
        % Apply morphological operations to remove noise and fill in holes.
        mask = morphologicalOperations(Sequence,mask);
        
        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
    end
    function mask = morphologicalOperations(Sequence,mask)
        switch Sequence
            case 'Traffic'
                mask = imfill(mask, 'holes');
                mask = imfill(mask,4,'holes');
                mask = bwareaopen(mask,80,4);
                mask = imopen(mask, strel('line',30,45));
                mask = imclose(mask,strel('diamond',20));
                
            case 'Highway'
                mask = imfill(mask,'holes');
                mask = bwareaopen(mask,30,4);
                mask = imclose(mask,strel('diamond',10));
                mask = imopen(mask,strel('diamond',2));
                mask = imfill(mask,'holes');
                
            case 'Road01'
                mask = imfill(mask, 'holes');
                mask = imopen(mask, strel('rectangle', [7,7]));
                mask = imfill(mask, 'holes');
        end
    end
    function predictNewLocationsOfTracks()
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;
            
            % Predict the current location of the track.
            predictedCentroid = predict(tracks(i).kalmanFilter);
            
            % Shift the bounding box so that its center is at
            % the predicted location.
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
    end
    function [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment()
        
        nTracks = length(tracks);
        nDetections = size(centroids, 1);
        
        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end
        
        % Solve the assignment problem.
        costOfNonAssignment = 20;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end
    function updateAssignedTracks()
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
            centroid = centroids(detectionIdx, :);
            bbox = bboxes(detectionIdx, :);
            
            % Correct the estimate of the object's location
            % using the new detection.
            correct(tracks(trackIdx).kalmanFilter, centroid);
            
            % Replace predicted bounding box with detected
            % bounding box.
            tracks(trackIdx).bbox = bbox;
            
            
            % Speed trackers
            x = double(bbox(1)); y = double(bbox(2)); w = double(bbox(3)); h = double(bbox(4));
            c_x = (x+(x+w))/2; c_y = (y+(y+h))/2;
            prev_centroid = speed_tracks(trackIdx).centroid;
            speed_tracks(trackIdx).centroid = [c_x, c_y];
            
            if c_x<=size(frame,2) && c_y<=size(frame,1) && ~(x<=1 || y<=1)
                speed_tracks(trackIdx).status = 1;
            elseif x<=1 || y<=1
                speed_tracks(trackIdx).status = 2;
            else
                speed_tracks(trackIdx).status = 0;
            end
            if speed_tracks(trackIdx).status == 1;
                speed_tracks(trackIdx).displacement = speed_tracks(trackIdx).displacement + sqrt((c_x-double(prev_centroid(1)))^2 + (c_y-double(prev_centroid(2)))^2);
                speed_tracks(trackIdx).frame_count = speed_tracks(trackIdx).frame_count + 1;
            end
            
            
            
            % Update track's age.
            tracks(trackIdx).age = tracks(trackIdx).age + 1;
            
            % Update visibility.
            tracks(trackIdx).totalVisibleCount = ...
                tracks(trackIdx).totalVisibleCount + 1;
            tracks(trackIdx).consecutiveInvisibleCount = 0;
        end
    end
    function updateUnassignedTracks()
        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
            speed_tracks(ind).frame_count = speed_tracks(ind).frame_count + 1;
        end
    end
    function deleteLostTracks()
        if isempty(tracks)
            return;
        end
        
        %Highway 5,4 ; Traffic 3,3
        invisibleForTooLong = 3;
        ageThreshold = 3;
        
        % Compute the fraction of the track's age for which it was visible.
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;
        
        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
        
        % Delete lost tracks.
        tracks = tracks(~lostInds);
        speed_tracks = speed_tracks(~lostInds);
    end
    function createNewTracks()
        centroids = centroids(unassignedDetections, :);
        bboxes = bboxes(unassignedDetections, :);
        
        for i = 1:size(centroids, 1)
            
            centroid = centroids(i,:);
            bbox = bboxes(i, :);
            
            % Create a Kalman filter object.
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, [200, 50], [100, 25], 100);
            
            % Create a new track.
            newTrack = struct(...
                'id', nextId, ...
                'bbox', bbox, ...
                'kalmanFilter', kalmanFilter, ...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0);
            
            % Speed trackers
            x = bbox(1); y = bbox(2); w = bbox(3); h = bbox(4);
            c_x = (x+(x+w))/2; c_y = (y+(y+h))/2;
            
            new_speed_track = struct(...
                'status', 0, ...
                'centroid', [c_x, c_y], ...
                'frame_count', 1, ...
                'displacement', 0, ...
                'speed', -1);
            
            % Add it to the array of tracks.
            tracks(end + 1) = newTrack;
            speed_tracks(end+1) = new_speed_track;
            
            % Increment the next id.
            nextId = nextId + 1;
        end
    end

    function updateSpeeds()
        for i=1:length(speed_tracks)
            if strcmp(Sequence,'Traffic')
                speed_tracks(i).speed =params.pixXframe2kmXh_traffic*speed_tracks(i).displacement/speed_tracks(i).frame_count;                

                disp(['New speed approximation: ', num2str(speed_tracks(i).speed), ' km/h']);
            elseif strcmp(Sequence, 'Highway')
                speed_tracks(i).speed = params.pixXframe2kmXh_highway*speed_tracks(i).displacement/speed_tracks(i).frame_count;
                %disp(['New speed approximation: ', num2str(speed_tracks(i).speed), ' km/h']);

            elseif strcmp(Sequence, 'Road01')
                speed_tracks(i).speed = params.pixXframe2kmXh_ownVideo*speed_tracks(i).displacement/speed_tracks(i).frame_count;
                %disp(['New speed approximation: ', num2str(speed_tracks(i).speed), ' km/h']);
            end
      

        end
        %disp(['New speed approximation: ', num2str(speed_tracks(i).speed), ' km/h']);
        
    end

    function displayTrackingResults()
        % Convert the frame and the mask to uint8 RGB.
        frame = im2uint8(frame);
        mask = uint8(repmat(mask, [1, 1, 3])) .* 255;
        
        minVisibleCount = 8;
        if ~isempty(tracks)
            
            % Noisy detections tend to result in short-lived tracks.
            % Only display tracks that have been visible for more than
            % a minimum number of frames.
            reliableTrackInds = ...
                [tracks(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = tracks(reliableTrackInds);
            reliableSpeedTracks = speed_tracks(reliableTrackInds);
            
            % Display the objects. If an object has not been detected
            % in this frame, display its predicted bounding box.
            if ~isempty(reliableTracks)
                % Get bounding boxes.
                bboxes = cat(1, reliableTracks.bbox);
                
                % Get ids.
                ids = int32([reliableTracks(:).id]);
                speeds = [reliableSpeedTracks(:).speed];
                
                % Create labels for objects indicating the ones for
                % which we display the predicted rather than the actual
                % location.
                labels = cellstr(int2str(ids'));
                colors = cellstr(int2str(ids'));
                for i=1:length(ids)
                    if reliableSpeedTracks(i).status == 0
                        labels{i} = [int2str(ids(i)), ' ', '(tracking...)'];
                        %                      elseif reliableSpeedTracks(i).status == 1
                        %                         labels{i} = [int2str(ids(i)), ' ', '(computing...)'];
                    else
                        labels{i} = [int2str(ids(i)), '     ', num2str(speeds(i)), ' km/h'];
                    end
                    if speeds(i) > maximum_speed
                        colors{i} = 'red';
                    else
                        colors{i} = 'yellow';
                    end
                end
                
                predictedTrackInds = ...
                    [reliableTracks(:).consecutiveInvisibleCount] > 0;
                isPredicted = cell(size(labels));
                isPredicted(predictedTrackInds) = {' predicted'};
                labels = strcat(labels, isPredicted);
                
                % Draw the objects on the frame.
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    bboxes, labels, 'Color', colors);
                
                % Draw the objects on the mask.
                mask = insertObjectAnnotation(mask, 'rectangle', ...
                    bboxes, labels, 'Color', colors);
                
            end
        end
        time_of_video = (num_frames/frameRate_video);
        density = uint8(60*(nextId - 1)/ time_of_video);
        frame = insertText(frame, [10 10], density, 'BoxOpacity', 1, ...
            'FontSize', 14);
        mask = insertText(mask, [10 10], density, 'BoxOpacity', 1, ...
            'FontSize', 14);
        % Display the mask and the frame.
        obj.maskPlayer.step(mask);
        obj.videoPlayer.step(frame);
    end

    function saveTrackingResults(writerObj)
        writeVideo(writerObj, frame);
        pause(0.03)
    end
end