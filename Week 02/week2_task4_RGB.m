clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed

%Directory where the masks of the different sets are placed
directory_sequence = '../Database/Week02/highway/';
%directory_sequence = '../Database/Week02/fall/';
%directory_sequence = '../Database/Week02/traffic/';

directory_imagesIn = strcat(directory_sequence, 'input/');
dirIn = dir([directory_imagesIn '/*.jpg']);
ext='.jpg';
directory_imagesGT = strcat(directory_sequence, 'groundtruth/');
dirGT = dir([directory_imagesGT '/*.png']);

[dim1, dim2, dim3] = size(imread(strcat(directory_imagesIn, dirIn(1).name)));
imagesSeg = zeros(dim1, dim2, length(dirIn));

percentage = 0.5;
train = 1:floor(percentage*length(dirIn));
test = floor(percentage*length(dirIn)) + 1:length(dirIn);

images1 = zeros(dim1, dim2, dim3,length(train));
images2 = zeros(dim1, dim2, dim3,length(test));
imagesSeg = zeros(dim1, dim2,length(test));
alpha=0.088;
%0.001 muy sobresegmentado. 0.01 sobresegmentado 0.05 bien, probar cerca.

%For the first 50% of the images from the dataset, the background model is
%computed.

for i =train
    images1(:,:,:,i) = im2double(imread(strcat(directory_imagesIn, dirIn(i).name)));
end


mu = zeros(dim1,dim2,dim3);
sigma = zeros(dim1,dim2,dim3);

for m = 1:dim1
    for n = 1:dim2
        for k = 1:dim3
            mu(m,n,k)=mean(images1(m,n,k,:));
            sigma(m,n,k)=std(images1(m,n,k,:)); 
        end
    end
end

%For the second 50% of the images from the dataset, the foreground is
%segmented
step=0;
for alpha= 0.01:0.01:0.1;
    step=step+1;
for i = test
    images2(:,:,:,i-length(test)+1) = im2double(imread(strcat(directory_imagesIn, dirIn(i).name)));
    imagesSeg(:,:,i-length(test)+1) = ...
        abs(images2(:,:,1,i-length(test)+1)-mu(:,:,1)) >= alpha*(2+sigma(:,:,1)) &...
        abs(images2(:,:,2,i-length(test)+1)-mu(:,:,2)) >= alpha*(2+sigma(:,:,2)) &...
        abs(images2(:,:,3,i-length(test)+1)-mu(:,:,3)) >= alpha*(2+sigma(:,:,3));
end

%% 

%Evaluation step

    TP_images = zeros(length(test), 1);
    FP_images = zeros(length(test), 1);
    FN_images = zeros(length(test), 1);
    TN_images = zeros(length(test), 1);
 

 for i = test
        
        imageGT =imread(strcat(directory_imagesGT,dirGT(i).name));
        image = imagesSeg(:,:,i-length(test)+1);
        [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(image, imageGT);
        TP_images(i-length(test)+1) = pixelTP;
        FP_images(i-length(test)+1) = pixelFP;
        FN_images(i-length(test)+1) = pixelFN;
        TN_images(i-length(test)+1) = pixelTN;
        
 end
    [pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
%     metrics = [pixelTP,pixelFP,pixelFN,pixelTN];
%     metrics2 = [pixelPrecision, pixelRecall,pixelFMeasure];
    
 
 %Uncomment this lines so an analysis in relation to alpha is performed (remember to change the for sentence too)   
    metrics(:,uint8(step)) = [pixelTP,pixelFP,pixelFN,pixelTN];
    metrics2(:,uint8(step)) = [pixelPrecision, pixelRecall,pixelFMeasure];
end
alpha= 0.01:0.01:0.1;
auc = graphs(alpha,metrics,metrics2)
%     x = ['highway','fall','traffic'];
% traffic = 0.4372(auc) 0.4714
%     y=[0.6735  ;0.4437 ;0.6311]
 
% plot(alpha,metrics2(1,:),'r',alpha,metrics2(2,:),'g',alpha,metrics2(3,:),'b');
% title 'Precision Recall Fmeasure'
% xlabel('Alpha')
% ylabel('Value')
% legend('Precision','Recall','Fmeasure')