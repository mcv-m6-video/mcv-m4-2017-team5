clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed

directory_imagesIn = 'Database/highway/input/';
directory_imagesGT = 'Database/highway/groundtruth/';

dirIn = dir([directory_imagesIn '/*.jpg']);
dirGT = dir([directory_imagesGT '/*.png']);

images1 = zeros(240,320,100);
images2 = zeros(240,320,100);
imagesSeg = zeros(240,320,100);
alpha=0.088;


%For the first 50% of the images from the dataset, the background model is
%computed.

for i = 1:length(dirIn)/2
    images1(:,:,i) = rgb2gray(im2double(imread(dirIn(i).name)));
end


mu = zeros(240,320);
sigma = zeros(240,320);

for m = 1:240
    for n = 1:320
       
            mu(m,n)=mean(images1(m,n,:));
            sigma(m,n)=std(images1(m,n,:)); 
      
    end
end

%For the second 50% of the images from the dataset, the foreground is
%segmented
% for alpha = 0.001:0.001:0.2
for i = length(dirIn)/2+1:length(dirIn)
    images2(:,:,i-length(dirIn)/2) = rgb2gray(im2double(imread(dirIn(i).name)));
    imagesSeg(:,:,i-length(dirIn)/2) = abs(images2(:,:,i-length(dirIn)/2)-mu(:,:)) >= alpha*(2+sigma(:,:));
       
end

%% 

%Evaluation step

    TP_images = zeros(length(dirGT), 1);
    FP_images = zeros(length(dirGT), 1);
    FN_images = zeros(length(dirGT), 1);
    TN_images = zeros(length(dirGT), 1);
 

 for i = length(dirIn)/2+1:length(dirIn)
        
        imageGT =imread(strcat(directory_imagesGT,dirGT(i).name));
        image = imagesSeg(:,:,i-length(dirIn)/2);
        [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(image, imageGT);
        TP_images(i) = pixelTP;
        FP_images(i) = pixelFP;
        FN_images(i) = pixelFN;
        TN_images(i) = pixelTN;
        
 end
    [pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
    metrics = [pixelTP,pixelFP,pixelFN,pixelTN];
    metrics2 = [pixelPrecision, pixelRecall,pixelFMeasure];
    
 
 %Uncomment this lines so an analysis in relation to alpha is performed (remember to change the for sentence too)   
%     metrics(:,uint8(alpha*1000)) = [pixelTP,pixelFP,pixelFN,pixelTN];
%     metrics2(:,uint8(alpha*1000)) = [pixelPrecision, pixelRecall,pixelFMeasure];
end
% 
% plot(alpha,metrics2(1,:),'r',alpha,metrics2(2,:),'g',alpha,metrics2(3,:),'b');
% title 'Precision Recall Fmeasure'
% xlabel('Alpha')
% ylabel('Value')
% legend('Precision','Recall','Fmeasure')