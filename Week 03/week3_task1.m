% clear all
% close all
% clc
addpath(genpath('.'))

for seq=1:3
    switch seq
        case 1
            %Directory where the masks of the different sets are placed
            directory_sequence = '../Database/Week02/highway/';
            InitialFrame = 1050;
            FinalFrame = 1350;
            video='highway';
            k=3;
            %LearningRate=0.014;
            BackgroundRatio=0.4;
        case 2
            %Directory where the masks of the different sets are placed
            directory_sequence = '../Database/Week02/fall/';
            InitialFrame = 1460;
            FinalFrame = 1560;
            video='fall';
            k=3;
            %LearningRate=0.03;
            BackgroundRatio=0.6;
        case 3
            %Directory where the masks of the different sets are placed
            directory_sequence = '../Database/Week02/traffic/';
            InitialFrame = 950;
            FinalFrame = 1050;
            video='traffic';
            k=3;
            %LearningRate=0.043;
            BackgroundRatio=0.6;
    end
    
    directory_imagesIn = strcat(directory_sequence, 'input/');
    dirIn = dir([directory_imagesIn '/*.jpg']);
    directory_imagesGT = strcat(directory_sequence, 'groundtruth/');
    dirGT = dir([directory_imagesGT '/*.png']);

    Results=[];
    TP_images = zeros(length(dirIn), 1);
    FP_images = zeros(length(dirIn), 1);
    FN_images = zeros(length(dirIn), 1);
    TN_images = zeros(length(dirIn), 1);

    conn=4;
    filename = strcat('Video_',video,'_filled_',num2str(conn),'.gif');

    for LearningRate=0.001:0.001:1
        detector=vision.ForegroundDetector('NumTrainingFrames',(FinalFrame-InitialFrame)./2, 'LearningRate',LearningRate,'MinimumBackgroundRatio',BackgroundRatio,'NumGaussians',k,'InitialVariance',30^2);

        for i=1:(FinalFrame-InitialFrame)
            image = imread(strcat(directory_imagesIn, dirIn(i).name));
            grayimage = rgb2gray(image);
            imageGT = imread(strcat(directory_imagesGT,dirGT(i).name));

            foreground = step(detector,grayimage);

            foregroundfilled=imfill(foreground,conn,'holes');   
            [TP_images,FP_images,FN_images,TN_images] = Metrics(imageGT,foregroundfilled,i,TP_images,FP_images,FN_images,TN_images);

            %create_gift(image,foreground,foregroundfilled,filename,i);

        end

        [pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
        metrics = [pixelPrecision, pixelRecall,pixelFMeasure];
        Results=[LearningRate metrics;Results];
    end
    auc=graphs(Results)
end


