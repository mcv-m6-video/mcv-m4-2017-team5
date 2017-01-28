%Video stabilization from
%http://es.mathworks.com/help/vision/examples/video-stabilization-using-point-feature-matching.html
function point_feature_matching(filename,directory_results)
    hVideoSrc = vision.VideoFileReader(filename, 'ImageColorSpace', 'Intensity');

    hVPlayer = vision.VideoPlayer; % Create video viewer

    % Process all frames in the video
    movMean = step(hVideoSrc);
    imgB = movMean;
    imgBp = imgB;
    correctedMean = imgBp;
    ii = 2;
    Hcumulative = eye(3);


    %Gif
    imshow(zeros([240,320]));
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);
    imwrite(imind,cm,[directory_results,filesep,'stab.gif'],'gif','DelayTime',0,'Loopcount',inf);
    while ~isDone(hVideoSrc) && ii < 45
        % Read in new frame
        imgA = imgB; % z^-1
        imgAp = imgBp; % z^-1
        imgB = step(hVideoSrc);
        movMean = movMean + imgB;

        % Estimate transform from frame A to frame B, and fit as an s-R-t
        H = cvexEstStabilizationTform(imgA,imgB);
        HsRt = cvexTformToSRT(H);
        Hcumulative = HsRt * Hcumulative;
        imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

        compensated_frame=imfuse(imgAp,imgBp,'ColorChannels','red-cyan');

        % Display as color composite with last corrected frame
        step(hVPlayer, compensated_frame);
        correctedMean = correctedMean + imgBp;

        %Gif
        imshow(compensated_frame);
        frame = getframe(gcf);
        im = frame2im(frame);
        [imind, cm] = rgb2ind(im, 256);
        imwrite(imind,cm,[directory_results,filesep,'stab.gif'],'gif','DelayTime',0,'WriteMode','append');

        ii = ii+1;
    end
    correctedMean = correctedMean/(ii-2);
    movMean = movMean/(ii-2);

    % Here you call the release method on the objects to close any open files
    % and release memory.
    release(hVideoSrc);
    release(hVPlayer);

end