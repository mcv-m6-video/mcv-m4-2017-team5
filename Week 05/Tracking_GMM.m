function Tracking_GMM(video_file,output_videofile,Sequence)

% https://nl.mathworks.com/help/vision/examples/detecting-cars-using-gaussian-mixture-models.html
counter = 0;
counterPrevious = 0;

% Obtaining an initial video frame in which the moving objects are segmented
% from the background
foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 50,'LearningRate', 0.095,...
    'MinimumBackgroundRatio', 0.55);
videoReader = vision.VideoFileReader(video_file);

% Initialize videowriter
frame_rate=24;
writerObj = VideoWriter(output_videofile);
writerObj.FrameRate = frame_rate;
open(writerObj);

frame = step(videoReader); % read the next video frame
foreground = step(foregroundDetector, frame);

% Morphological opening to remove the noise and to fill gaps in the detected objects.
 se = strel('square', 6);
 filteredForeground = imopen(foreground, se);

% We find bounding boxes of each connected component corresponding to a
% moving car.
% Rejecting blobs which contain fewer than X pixels.
blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false, 'CentroidOutputPort', false  , ...
    'MinimumBlobArea',3000);  %traffic=3000
bbox = step(blobAnalysis, filteredForeground);

% we draw green boxes around them.
result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');

% The number of bounding boxes corresponds to the number of cars found in the video frame
numCars = size(bbox, 1);
result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, ...
    'FontSize', 14);
figure; imshow(result); title('Detected Cars');

% we process the remaining video frames.
videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
videoPlayer.Position(3:4) = [650,400];  % window size: [width, height]
se = strel('square', 3); % morphological filter for noise removal

while ~isDone(videoReader)

    frame = step(videoReader); % read the next video frame

    % Detect the foreground in the current video frame
    foreground = step(foregroundDetector, frame);

    % Use morphological opening to remove noise in the foreground
    %figure, imshow(foreground)
    
    if strcmp(Sequence,'Highway')
        mask = imfill(foreground,4,'holes');
        mask = bwareaopen(mask,30,4);
        mask = imclose(mask, strel('diamond', 7));
        mask = imopen(mask, strel('diamond', 5));
        filteredForeground = imfill(foreground,4,'holes');
    elseif strcmp(Sequence,'Traffic')
        mask = imfill(foreground,4,'holes');
        mask = bwareaopen(mask,80,4);
        mask = imopen(mask, strel('square', 12));
        mask = imopen(mask, strel('line',30,45));
        filteredForeground = imclose(mask,strel('diamond',20));
    end
    
    % Detect the connected components with the specified minimum area, and
    % compute their bounding boxes
    bbox = step(blobAnalysis, filteredForeground);
    
    % Draw bounding boxes around the detected cars
    result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
    % Display the number of cars found in the video frame
    numCars = size(bbox, 1);
    
    
    if numCars>counterPrevious
        counter = counter + 1;
    end
    counterPrevious=numCars;
    
    result = insertText(result, [10 10], counter, 'BoxOpacity', 1, ...
        'FontSize', 14);

    step(videoPlayer, result);  % display the results
    
   writeVideo(writerObj, result);
   pause(0.03)
end

release(videoReader); % close the video file