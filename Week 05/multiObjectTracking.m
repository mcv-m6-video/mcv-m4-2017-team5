function multiObjectTracking(file_video, output_videofile, background_estimation)


% Create System objects used for reading video, detecting moving objects,
% and displaying the results.
%Changes from Roque to Matlab Script:
%       -Morphological operations
%               Traffic:
%                 I = imfill(images(:,:,i),4,'holes');
%                 Iarea = bwareaopen(I,P,30);
%                 Icl = imopen(Iarea,se4); se4 = strel('line',10,45);
%                 Iocl = imclose(Icl,se2); se2 = strel('diamond',20);
%               Highway:
%       -InvisibleForTooLong = 5 (so cars are distinguished)
%       -Adding speed (required for our task)-> Using obj.OpticalFlow


obj = setupSystemObjects(file_video, background_estimation);

if strcmp(background_estimation, 'gaussian')
        background_model = obj.detector;
        final_mu_model = background_model(:, :, 1:3);
        final_sigma_model = background_model(:, :, 4:6);
end


tracks = initializeTracks(); % Create an empty array of tracks.

nextId = 1; % ID of the next track

% Initialize videowriter
frame_rate=24;
writerObj = VideoWriter(output_videofile);
writerObj.FrameRate = frame_rate;
open(writerObj);

% Detect moving objects, and track them across video frames.
while ~isDone(obj.reader)
    switch background_estimation
        case 'S&G'
            frame = readFrame();
            [centroids, bboxes, mask] = detectObjects(frame);
            
        case 'gaussian'
            frame = readFrame();
            [centroids, bboxes, mask] = detectObjects_recursive_gaussian(frame);
            
    end
    predictNewLocationsOfTracks();
    [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment();
    
    updateAssignedTracks();
    updateUnassignedTracks();
    deleteLostTracks();
    createNewTracks();
    
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
                obj.detector = train_background(file_video);
        end
        
        % Connected groups of foreground pixels are likely to correspond to moving
        % objects.  The blob analysis System object is used to find such groups
        % (called 'blobs' or 'connected components'), and compute their
        % characteristics, such as area, centroid, and the bounding box.
        
        obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 600);
        %         velocities = obj.OpticalFlowHS;
        %         print(velocities);
    end
    function background_model = train_background(file_video)
        switch file_video
            case '../Videos_last_week/Road_01_new_scale.avi'
                filename = '../Videos_last_week/Road_01_for_train.avi';
                v = VideoReader(filename);
                
                %Reading the video characteristics
                time = v.duration;
                frameRate = v.FrameRate;
                Height = uint32(v.Height);
                Width = uint32(v.Width);
                numFrames = uint32(frameRate*time);
                
            case 'other'
        end
        final_mu_model = zeros(Height, Width, 3);
        final_sigma_model = zeros(Height, Width, 3);
        full_images_train = zeros(Height, Width, 3, numFrames);
        for i = 1:numFrames
            full_images_train(:, :, :, i) = double(read(v,i));
        end
        for channel = 1:3
            images_train = shiftdim(full_images_train(:, :, channel, :));
            final_mu_model(:, :, channel) = mean(images_train, 4);
            final_sigma_model(:, :, channel) = std(images_train, 1, 4);
        end
        background_model =  cat(3, final_mu_model, final_sigma_model);
    end

    function tracks = initializeTracks()
        % create an empty array of tracks
        tracks = struct(...
            'id', {}, ...
            'bbox', {}, ...
            'kalmanFilter', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {});
    end
    function frame = readFrame()
        frame = obj.reader.step();
    end
    function [centroids, bboxes, mask] = detectObjects_recursive_gaussian(frame)
        alpha = 3;
        rho = 0.1;
        % Detect foreground.
        
        mask = ones(size(frame, 1), size(frame, 2));
        for channel = 1:3
            im = frame(:, :, channel);
            mu = final_mu_model(:, :, channel);
            sigma = final_sigma_model(:, :, channel);

            % Determine if a pixel is background or foreground
            segmentation = abs(im - mu) >= alpha*(2 + sigma);
            
            
            %Update background model with pixels labeled as background
            mu = (1 - segmentation).*(rho*im + (1 - rho)*mu) + segmentation.*mu;
            sigma = sqrt((1 - segmentation).*(rho.*(im - mu).^2 + (1 - rho).*sigma.^2) + segmentation.*sigma.^2);
            
            final_mu_model(:, :, channel) = mu;
            final_sigma_model(:, :, channel) = sigma;
        end
        
        mask = morphological_operators(mask);
        
        
        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
    end
    function [centroids, bboxes, mask] = detectObjects(frame)
        
        % Detect foreground.
        mask = obj.detector.step(frame);
        
        mask = morphological_operators(mask);
        
        
        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
    end
    function [mask] = morphological_operators(mask)
        
        % Apply morphological operations to remove noise and fill in holes.
        %         mask = imopen(mask, strel('rectangle', [20,20]));
        %         mask = imclose(mask, strel('rectangle', [5, 5]));
        %         mask = imfill(mask, 'holes');
        mask = imfill(mask, 4, 'holes');
        mask = bwareaopen(mask, 80, 4);
        mask = imopen(mask, strel('line', 30, 45));
        mask = imclose(mask, strel('diamond', 20));
        
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
        end
    end
    function deleteLostTracks()
        if isempty(tracks)
            return;
        end
        
        invisibleForTooLong = 5;
        ageThreshold = 4;
        
        % Compute the fraction of the track's age for which it was visible.
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;
        
        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
        
        % Delete lost tracks.
        tracks = tracks(~lostInds);
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
            
            % Add it to the array of tracks.
            tracks(end + 1) = newTrack;
            
            % Increment the next id.
            nextId = nextId + 1;
        end

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
            
            % Display the objects. If an object has not been detected
            % in this frame, display its predicted bounding box.
            if ~isempty(reliableTracks)
                % Get bounding boxes.
                bboxes = cat(1, reliableTracks.bbox);
                
                % Get ids.
                ids = int32([reliableTracks(:).id]);
                
                % Create labels for objects indicating the ones for
                % which we display the predicted rather than the actual
                % location.
                labels = cellstr(int2str(ids'));
                predictedTrackInds = ...
                    [reliableTracks(:).consecutiveInvisibleCount] > 0;
                isPredicted = cell(size(labels));
                isPredicted(predictedTrackInds) = {' predicted'};
                labels = strcat(labels, isPredicted);
                
                % Draw the objects on the frame.
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    bboxes, labels);
                
                % Draw the objects on the mask.
                mask = insertObjectAnnotation(mask, 'rectangle', ...
                    bboxes, labels);
            end
        end
        
        % Display the mask and the frame.
        obj.maskPlayer.step(mask);
        obj.videoPlayer.step(frame);
    end

    function saveTrackingResults(writerObj)
        writeVideo(writerObj, frame);
    end
end