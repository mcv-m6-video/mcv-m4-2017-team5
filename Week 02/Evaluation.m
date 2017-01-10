function [TP_images,FP_images,FN_images,TN_images] = Evaluation(Sequence,directory_imagesIn,dirIn,directory_imagesGT,dirGT,filename,video) 
       
TP_images = zeros(length(Sequence), 1);
FP_images = zeros(length(Sequence), 1);
FN_images = zeros(length(Sequence), 1);
TN_images = zeros(length(Sequence), 1);

    for i=1:length(dirIn)
%         imwrite(Sequence(:,:,i),[path_results 'ResultsTask3/' video '/' dirIn(i).name ]);
        scene = imread(strcat(directory_imagesIn,dirIn(i).name));
        imageGT = imread(strcat(directory_imagesGT,dirGT(i).name));
        [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(Sequence(:,:,i), imageGT);
        TP_images(i) = pixelTP;
        FP_images(i) = pixelFP;
        FN_images(i) = pixelFN;
        TN_images(i) = pixelTN;
        %FMeasure = (2*TP_images)./(2*TP_images + FN_images + FP_images);

        subplot(121);
        imshow(scene);
        subplot(122),
        imshow(Sequence(:,:,i),[]);
    %   subplot(2,2,[3 4]);
    %   plot(1:length(dirIn),FMeasure);
    %   axis([0 200 0 1])

        frame = getframe(gcf);
        im=frame2im(frame);
        [imind,cm]=rgb2ind(im,256);

        % On the first loop, create the file. In subsequent loops, append.
        if i==1
            imwrite(imind,cm,filename,'gif','DelayTime',0,'Loopcount',inf);
        else
            imwrite(imind,cm,filename,'gif','DelayTime',0,'WriteMode','append');
        end
    end
end