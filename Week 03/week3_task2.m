% clear all
% close all
% clc
addpath(genpath('.'))

seq = 1;

switch seq
    case 1
        %Directory where the masks of the different sets are placed
        directory_sequence = '../Database/Week02/highway/';
        InitialFrame = 1050;
        FinalFrame = 1350;
        Sequence='highway';
        k=3;
        %LearningRate=0.014;
        BackgroundRatio=0.4;
    case 2
        %Directory where the masks of the different sets are placed
        directory_sequence = '../Database/Week02/fall/';
        InitialFrame = 1460;
        FinalFrame = 1560;
        Sequence='fall';
        k=3;
        %LearningRate=0.03;
        BackgroundRatio=0.6;
    case 3
        %Directory where the masks of the different sets are placed
        directory_sequence = '../Database/Week02/traffic/';
        InitialFrame = 950;
        FinalFrame = 1050;
        Sequence='traffic';
        k=3;
        %LearningRate=0.043;
        BackgroundRatio=0.6;
end

directory_imagesIn = strcat(directory_sequence, 'input/');
dirIn = dir([directory_imagesIn '/*.jpg']);
directory_imagesGT = strcat(directory_sequence, 'groundtruth/');
dirGT = dir([directory_imagesGT '/*.png']);


Results=[];
Results2=[];

TP_images = zeros(length(dirIn), 1);
FP_images = zeros(length(dirIn), 1);
FN_images = zeros(length(dirIn), 1);
TN_images = zeros(length(dirIn), 1);

conn=4;
filename = strcat('Video_',Sequence,'_filled_',num2str(conn),'.gif');

detector=vision.ForegroundDetector('NumTrainingFrames',(FinalFrame-InitialFrame)./2, 'LearningRate',LearningRate,'MinimumBackgroundRatio',BackgroundRatio,'NumGaussians',k,'InitialVariance',30^2);
for P=0:10:100
%P=100;
    for LearningRate=0.001:0.001:1
        detector=vision.ForegroundDetector('NumTrainingFrames',(FinalFrame-InitialFrame)./2, 'LearningRate',LearningRate,'MinimumBackgroundRatio',BackgroundRatio,'NumGaussians',k,'InitialVariance',30^2);

        for i=1:(FinalFrame-InitialFrame)
            image = imread(strcat(directory_imagesIn, dirIn(i).name));
            grayimage = rgb2gray(image);
            imageGT = imread(strcat(directory_imagesGT,dirGT(i).name));

            foreground = step(detector,grayimage);

            foregroundfilled=imfill(foreground,conn,'holes');
            foregroundprocessed = bwareaopen(foregroundfilled,P,conn);

            [TP_images,FP_images,FN_images,TN_images] = Metrics(imageGT,foregroundprocessed,i,TP_images,FP_images,FN_images,TN_images);

            %create_gift(image,foreground,foregroundfilled,foregroundprocessed,filename,i);

        end

        [pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
        metrics = [pixelPrecision, pixelRecall,pixelFMeasure];
        Results=[LearningRate metrics;Results];
    end
    auc=trapz(Results(:,3),Results(:,2));
    Results2 = [P auc;Results2];
end

Results2(isnan(Results2))=0;

hold on
plot(Results2(:,1),Results2(:,2))
title (strcat('AUC in function of P - ' , Sequence, ' sequence'))
xlabel('P')
ylabel('AUC')
auc=trapz(Results2(:,1),Results2(:,2));

