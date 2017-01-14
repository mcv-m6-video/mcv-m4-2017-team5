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

if strcmp(directory_sequence,'../Database/Week02/highway/')
    InitialFrame = 1050;
    FinalFrame = 1350;
    video='highway';
    k=3;
    LearningRate=0.014;
    BackgroundRatio=0.4;
elseif strcmp(directory_sequence,'../Database/Week02/fall/')
    InitialFrame = 1460;
    FinalFrame = 1560;
    video='fall';
    k=2;
    LearningRate=0.024;
    BackgroundRatio=0.8;
else
    InitialFrame = 950;
    FinalFrame = 1050;
    video='traffic';
end

TP_images = zeros(length(dirIn), 1);
FP_images = zeros(length(dirIn), 1);
FN_images = zeros(length(dirIn), 1);
TN_images = zeros(length(dirIn), 1);

conn=4;
filename = strcat('Video_',video,'_filled_',num2str(conn),'.gif');

detector=vision.ForegroundDetector('NumTrainingFrames',(FinalFrame-InitialFrame)./2, 'LearningRate',LearningRate,'MinimumBackgroundRatio',BackgroundRatio,'NumGaussians',k,'InitialVariance',30^2);

for i=1:(FinalFrame-InitialFrame)
    image = imread(strcat(directory_imagesIn, dirIn(i).name));
    grayimage = rgb2gray(image);
    imageGT = imread(strcat(directory_imagesGT,dirGT(i).name));

    foreground = step(detector,grayimage);
    
    foregroundfilled=imfill(foreground,conn,'holes');   
    [TP_images,FP_images,FN_images,TN_images] = Metrics(imageGT,foregroundfilled,i,TP_images,FP_images,FN_images,TN_images);

    create_gift(image,foreground,foregroundfilled,filename,i);
    
end

[pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
metrics = [pixelPrecision, pixelRecall,pixelFMeasure];