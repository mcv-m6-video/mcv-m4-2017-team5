% clear all
% close all
% clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed
directory_sequence = '../Database/Week02/highway/';
%directory_sequence = '../Database/Week02/fall/';
%directory_sequence = '../Database/Week02/traffic/';

directory_imagesIn = strcat(directory_sequence, 'input/');
dirIn = dir([directory_imagesIn '/*.jpg']);
directory_imagesGT = strcat(directory_sequence, 'groundtruth/');
dirGT = dir([directory_imagesGT '/*.png']);

[dim1, dim2, dim3] = size(imread(strcat(directory_imagesIn, dirIn(1).name)));
imagesSeg = zeros(dim1, dim2, length(dirIn));

if strcmp(directory_sequence,'../Database/Week02/highway/')
    InitialFrame = 1050;
    FinalFrame = 1350;
    video='highway';
elseif strcmp(directory_sequence,'../Database/Week02/fall/')
    InitialFrame = 1460;
    FinalFrame = 1560;
    video='fall';
else
    InitialFrame = 950;
    FinalFrame = 1050;
    video='traffic';
end

Results=[];
TP_images = zeros(length(dirIn), 1);
FP_images = zeros(length(dirIn), 1);
FN_images = zeros(length(dirIn), 1);
TN_images = zeros(length(dirIn), 1);


for k=3:6
    for LearningRate=0.001:0.001:0.1
        for BackgroundRatio=0:0.1:1
            detector=vision.ForegroundDetector('NumTrainingFrames',(FinalFrame-InitialFrame)./2, 'LearningRate',LearningRate,'MinimumBackgroundRatio',BackgroundRatio,'NumGaussians',k,'InitialVariance',30^2);

            for i=1:(FinalFrame-InitialFrame)
                image = imread(strcat(directory_imagesIn, dirIn(i).name));
                grayimage = rgb2gray(image);
                imageGT = imread(strcat(directory_imagesGT,dirGT(i).name));

                foreground = step(detector,grayimage);

                [TP_images,FP_images,FN_images,TN_images] = Metrics(imageGT,foreground,i,TP_images,FP_images,FN_images,TN_images);

            end

            [pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
            metrics = [pixelTP,pixelFP,pixelFN,pixelTN];
            metrics2 = [pixelPrecision, pixelRecall,pixelFMeasure];
            
            Results=[k LearningRate BackgroundRatio metrics2; Results];
        end
    end
end
Results(isnan(Results))=0;
[maxF1,ind] = max(Results(:,6));
Results(ind,:)
