clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed

directory_imagesGT = '../Database/highway/groundtruth/';
directory_scene = '../Database/highway/input/';
directory_imagesA = '../Results_given_week01/results_highway_changedetection/test_A/';
directory_imagesB = '../Results_given_week01/results_highway_changedetection/test_B/';
dirGT = dir([directory_imagesGT '/*.png']);
dirSc = dir([directory_scene '/*.jpg']);
dirA = dir([directory_imagesA '/*.png']);
dirB = dir([directory_imagesB '/*.png']);

TP_images = zeros(length(dirGT), 1);
FP_images = zeros(length(dirGT), 1);
FN_images = zeros(length(dirGT), 1);
TN_images = zeros(length(dirGT), 1);

filename = 'videoB.gif';
for test = 2:2  
    switch test
        case 1
            direct = dirA;
            directory_images = directory_imagesA;
        case 2
            direct = dirB;
            directory_images = directory_imagesB;
    end
    for i = 1:length(direct)
        
        imageGT=imread(strcat(directory_imagesGT,dirGT(i).name));
        image=imread(strcat(directory_images,direct(i).name));
        scene = imread(strcat(directory_scene,dirSc(i).name));
        [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(image, imageGT);
        TP_images(i) = pixelTP;
        FP_images(i) = pixelFP;
        FN_images(i) = pixelFN;
        TN_images(i) = pixelTN;
        FMeasure = (2*TP_images)./(2*TP_images + FN_images + FP_images);

        subplot(221);
        imshow(scene);
        subplot(222),
        imshow(image,[]);
        subplot(2,2,[3 4]);
        plot(1:200,FMeasure);
        axis([0 200 0 1])



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
