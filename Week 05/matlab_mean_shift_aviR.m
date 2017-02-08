function matlab_mean_shift_avi(output_videofile,Sequence)

if strcmp(Sequence, 'Traffic')
       File = '../Database/Week02/trafficvideo/traffic_croped.avi';
       File_ForeG = '../Database/Week02/trafficvideo/traffic_fore_croped.avi';
elseif strcmp(Sequence,'Highway') 
       File = '../Database/Week02/highwayvideo/highway_croped.avi';
       File_ForeG = '../Database/Week02/highwayvideo/high_fore_croped.avi';
end

% Initialize videowriter
frame_rate=24;
writerObj = VideoWriter(output_videofile);
writerObj.FrameRate = frame_rate;
open(writerObj);

    % Create system objects used for reading video, detecting moving objects,
    % and displaying the results.
    obj = setupSystemObjects();

    tracks = initializeTracks(); % Create an empty array of tracks.

    nextId = 1; % ID of the next track

    % Detect moving objects, and track them across video frames.
    while ~isDone(obj.reader) && ~isDone(obj.foreground_reader)
        frame = obj.reader.step();
        mask = obj.foreground_reader.step();
        [bboxes] = detectObjects(mask);
        predictNewLocationsOfTracks();
        [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment();

        updateAssignedTracks();
        updateUnassignedTracks();
        deleteLostTracks();
        createNewTracks();

        displayTrackingResults();
    end

    %% Create System Objects
    % Create System objects used for reading the video frames, detecting
    % foreground objects, and displaying results.

    function obj = setupSystemObjects()
        % Initialize Video I/O
        % Create objects for reading a video from a file, drawing the tracked
        % objects in each frame, and playing the video.
        
        % Create a video file reader.

        obj.reader = vision.VideoFileReader(File);
        obj.foreground_reader = vision.VideoFileReader(File_ForeG);
       % obj.reader = vision.VideoFileReader('../traffic.avi');
        %obj.foreground_reader = vision.VideoFileReader('../foreground_traffic.avi');
        
        % Create two video players, one to display the video,
        % and one to display the foreground mask.
        obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
        obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
        

        % Connected groups of foreground pixels are likely to correspond to moving
        % objects.  The blob analysis system object is used to find such groups
        % (called 'blobs' or 'connected components'), and compute their
        % characteristics, such as area, centroid, and the bounding box.
        
        if strcmp(Sequence, 'Highway')       
            obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 3500, 'Connectivity',4); %MinimumBlobArea Traffic: 400; Highway: 180
        
        elseif strcmp(Sequence, 'Traffic')
            obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 400, 'Connectivity',4); %MinimumBlobArea Traffic: 400; Highway: 180
        end
    end
    
    %% Initialize Tracks
    % The |initializeTracks| function creates an array of tracks, where each
    % track is a structure representing a moving object in the video. The
    % purpose of the structure is to maintain the state of a tracked object.
    % The state consists of information used for detection to track assignment,
    % track termination, and display. 
    %
    % The structure contains the following fields:
    %
    % * |id| :                  the integer ID of the track
    % * |bbox| :                the current bounding box of the object; used
    %                           for display
    % * |kalmanFilter| :        a Kalman filter object used for motion-based
    %                           tracking
    % * |age| :                 the number of frames since the track was first
    %                           detected
    % * |totalVisibleCount| :   the total number of frames in which the track
    %                           was detected (visible)
    % * |consecutiveInvisibleCount| : the number of consecutive frames for 
    %                                  which the track was not detected (invisible).
    %
    % Noisy detections tend to result in short-lived tracks. For this reason,
    % the example only displays an object after it was tracked for some number
    % of frames. This happens when |totalVisibleCount| exceeds a specified 
    % threshold.    
    %
    % When no detections are associated with a track for several consecutive
    % frames, the example assumes that the object has left the field of view 
    % and deletes the track. This happens when |consecutiveInvisibleCount|
    % exceeds a specified threshold. A track may also get deleted as noise if 
    % it was tracked for a short time, and marked invisible for most of the of 
    % the frames.      
    
    function tracks = initializeTracks()
        % create an empty array of tracks
        tracks = struct(...
            'id', {}, ...
            'bbox', {}, ...
            'meanShift', {}, ...
            'score', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {});
    end

    %% Detect Objects
    % The |detectObjects| function returns the centroids and the bounding boxes
    % of the detected objects. It also returns the binary mask, which has the 
    % same size as the input frame. Pixels with a value of 1 correspond to the
    % foreground, and pixels with a value of 0 correspond to the background.   
    %
    % The function performs motion segmentation using the foreground detector. 
    % It then performs morphological operations on the resulting binary mask to
    % remove noisy pixels and to fill the holes in the remaining blobs. 

    function [bboxes] = detectObjects(mask_frame)
        
        mask_frame = rgb2gray(mask_frame);
        mask_frame(mask_frame~=0) = 1;
        mask_frame = logical(mask_frame);
       
        % Perform blob analysis to find connected components.
        [~, ~, bboxes] = obj.blobAnalyser.step(mask_frame);
    end
    %% Predict New Locations of Existing Tracks
    % Use the Mean Shift algorithm to predict the centroid of each track in the
    % current frame, and update its bounding box accordingly.

    function predictNewLocationsOfTracks()
        for i = 1:length(tracks)
            
            hsv = rgb2hsv(frame);
            
            % Predict the current location of the track.
            [bbox, orientation, score] = step(tracks(i).meanShift, hsv(:,:,1));
            
            tracks(i).bbox = bbox;
            tracks(i).score = score;
        end
    end
    
    %% Assign Detections to Tracks
    % Assigning object detections in the current frame to existing tracks is
    % done by minimizing cost. The cost is defined as the negative
    % log-likelihood of a detection corresponding to a track.  
    %
    % The algorithm involves two steps: 
    %
    % Step 1: Compute the cost of assigning every detection to each track using
    % the |distance| method of the |vision.KalmanFilter| System object. The 
    % cost takes into account the Euclidean distance between the predicted
    % centroid of the track and the centroid of the detection. It also includes
    % the confidence of the prediction, which is maintained by the Kalman
    % filter. The results are stored in an MxN matrix, where M is the number of
    % tracks, and N is the number of detections.   
    %
    % Step 2: Solve the assignment problem represented by the cost matrix using
    % the |assignDetectionsToTracks| function. The function takes the cost 
    % matrix and the cost of not assigning any detections to a track.  
    %
    % The value for the cost of not assigning a detection to a track depends on
    % the range of values returned by the |distance| method of the 
    % |vision.KalmanFilter|. This value must be tuned experimentally. Setting 
    % it too low increases the likelihood of creating a new track, and may
    % result in track fragmentation. Setting it too high may result in a single 
    % track corresponding to a series of separate moving objects.   
    %
    % The |assignDetectionsToTracks| function uses the Munkres' version of the
    % Hungarian algorithm to compute an assignment which minimizes the total
    % cost. It returns an M x 2 matrix containing the corresponding indices of
    % assigned tracks and detections in its two columns. It also returns the
    % indices of tracks and detections that remained unassigned. 

    function [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment()
        
        nTracks = length(tracks);
        nDetections = size(bboxes, 1);
        
        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            G  = tracks(i).bbox;
            G2 = bboxes;
            
            for numberOfBBoxes = 1 : size(bboxes,1)
                acum = 0;
                for indexPositions = 1 : size(bboxes,2)
                    acum = sqrt(sum((G(indexPositions) - G2(numberOfBBoxes,indexPositions)) .^ 2));
                end
                cost(i, numberOfBBoxes) = acum;
            end
            
            %cost(i, :) = distance(tracks(i).MeanShift, centroids);
        end
        
        % Solve the assignment problem.
        costOfNonAssignment = 20;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end

    %% Update Assigned Tracks
    % The |updateAssignedTracks| function updates each assigned track with the
    % corresponding detection. It calls the |correct| method of
    % |vision.KalmanFilter| to correct the location estimate. Next, it stores
    % the new bounding box, and increases the age of the track and the total
    % visible count by 1. Finally, the function sets the invisible count to 0. 

    function updateAssignedTracks()
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
%            centroid = centroids(detectionIdx, :);
            bbox = bboxes(detectionIdx, :);
            
%             % Correct the estimate of the object's location
%             % using the new detection.
%             correct(tracks(trackIdx).meanShift, centroid);
            
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

    %% Update Unassigned Tracks
    % Mark each unassigned track as invisible, and increase its age by 1.

    function updateUnassignedTracks()
        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
        end
    end

    %% Delete Lost Tracks
    % The |deleteLostTracks| function deletes tracks that have been invisible
    % for too many consecutive frames. It also deletes recently created tracks
    % that have been invisible for too many frames overall. 

    function deleteLostTracks()
        if isempty(tracks)
            return;
        end
        
        invisibleForTooLong = 5;
        ageThreshold = 2;
        
        % Compute the fraction of the track's age for which it was visible.
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;
        
        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < 0.7) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
        
        % Delete lost tracks.
        tracks = tracks(~lostInds);
    end

    %% Create New Tracks
    % Create new tracks from unassigned detections. Assume that any unassigned
    % detection is a start of a new track. In practice, you can use other cues
    % to eliminate noisy detections, such as size, location, or appearance.

    function createNewTracks()
%        centroids = centroids(unassignedDetections, :);
        bboxes = bboxes(unassignedDetections, :);
        
        for i = 1:size(bboxes, 1)
            
            bbox = bboxes(i, :);
            
            % Create a Mean Shift object.
            tracker = vision.HistogramBasedTracker;
            
            hsv = rgb2hsv(frame);

            number_of_bins_in_histogram = 65;

            initializeObject(tracker, hsv(:,:,1) , bbox, number_of_bins_in_histogram);
             
            %kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
            %    centroid, [200, 50], [100, 25], 100);
            
            % Create a new track.
            newTrack = struct(...
                'id', nextId, ...
                'bbox', bbox, ...
                'meanShift', tracker, ...
                'score', 1, ...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0);
            
            % Add it to the array of tracks.
            tracks(end + 1) = newTrack;
            
            % Increment the next id.
            nextId = nextId + 1;
        end
    end

    %% Display Tracking Results
    % The |displayTrackingResults| function draws a bounding box and label ID 
    % for each track on the video frame and the foreground mask. It then 
    % displays the frame and the mask in their respective video players. 

    function displayTrackingResults()
        % Convert the frame and the mask to uint8 RGB.
        frame = im2uint8(frame);
        
        minVisibleCount = 3;
        if ~isempty(tracks)
              
            % Noisy detections tend to result in short-lived tracks.
            % Only display tracks that have been visible for more than 
            % a minimum number of frames.
            reliableTrackIndsForVisivility = ...
                [tracks(:).totalVisibleCount] > minVisibleCount;
            
            reliableTrackIndsForScore = [tracks(:).score] > 0.7;
            
            reliableTrackInds = reliableTrackIndsForVisivility .* reliableTrackIndsForScore;
            
            reliableTrackInds = find(reliableTrackInds == 1);
            
            reliableTracks = tracks(reliableTrackInds);
            
            % Display the objects. If an object has not been detected
            % in this frame, display its predicted bounding box.
            if ~isempty(reliableTrackInds)
            %if ~isempty(reliableTracks)
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
        writeVideo(writerObj, frame);
        pause(0.03)
    end

    %% Summary
    % This example created a motion-based system for detecting and
    % tracking multiple moving objects. Try using a different video to see if
    % you are able to detect and track objects. Try modifying the parameters
    % for the detection, assignment, and deletion steps.  
    %
    % The tracking in this example was solely based on motion with the
    % assumption that all objects move in a straight line with constant speed.
    % When the motion of an object significantly deviates from this model, the
    % example may produce tracking errors. Notice the mistake in tracking the
    % person labeled #12, when he is occluded by the tree. 
    %
    % The likelihood of tracking errors can be reduced by using a more complex
    % motion model, such as constant acceleration, or by using multiple Kalman
    % filters for every object. Also, you can incorporate other cues for
    % associating detections over time, such as size, shape, and color. 
    
    displayEndOfDemoMessage(mfilename)
end