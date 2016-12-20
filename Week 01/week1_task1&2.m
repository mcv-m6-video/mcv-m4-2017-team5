clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed

directory_imagesGT = '../Database/highway/groundtruth/';
directory_imagesA = '../Results_given_week01/results_highway_changedetection/test_A/';
directory_imagesB = '../Results_given_week01/results_highway_changedetection/test_B/';
dirGT = dir([directory_imagesGT '/*.png']);
dirA = dir([directory_imagesA '/*.png']);
dirB = dir([directory_imagesB '/*.png']);


metrics = zeros(4,2);
metrics2 = zeros(3,2);
    TP_images = zeros(length(dirGT), 1);
    FP_images = zeros(length(dirGT), 1);
    FN_images = zeros(length(dirGT), 1);
    TN_images = zeros(length(dirGT), 1);

for test = 1:2   
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
        [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(image, imageGT);
        TP_images(i) = pixelTP;
        FP_images(i) = pixelFP;
        FN_images(i) = pixelFN;
        TN_images(i) = pixelTN;
        
    
    end
     [pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
    metrics(:,test)= [pixelTP,pixelFP,pixelFN,pixelTN];
    metrics2(:,test) = [pixelPrecision, pixelRecall,pixelFMeasure];
end

FMeasure = (2*TP_images)./(2*TP_images + FN_images + FP_images);
cumFM = cumsum(FMeasure);
cumTP = cumsum(TP_images);
cumTotalP=cumsum(TP_images + FP_images);

subplot(121),
plot(1:200,FMeasure);
title 'Fmeasure non Accumulative'
xlabel('Frame')
ylabel('Value')

subplot(122),
plot(1:200,cumFM);
title 'Fmeasure Accumulative'
xlabel('Frame')
ylabel('Value')

figure,
subplot(121),
plot(1:200,cumTP,'r',1:200,cumTotalP,'b')
legend('TP','TP+FP')
xlabel('Frame')
ylabel('Pixels')
title 'Accumulative'

subplot(122),
plot(1:200,TP_images,'r',1:200,TP_images+FP_images,'b')
legend('TP','TP+FP')
xlabel('Frame')
ylabel('Pixels')
title 'Non accumulative'






