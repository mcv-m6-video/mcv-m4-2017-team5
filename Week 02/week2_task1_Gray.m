clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed

directory_sequence = 'Database/Week02/highway/';
% directory_sequence = 'Database/Week02/fall/';
% directory_sequence = 'Database/Week02/traffic/';

directory_imagesIn = strcat(directory_sequence, 'input/');
directory_imagesGT = strcat(directory_sequence, 'groundtruth/');

dirIn = dir([directory_imagesIn '/*.jpg']);
dirGT = dir([directory_imagesGT '/*.png']);
percentage = 0.5;
alpha=0.07;

train = 1:floor(percentage*length(dirIn));
test = floor(percentage*length(dirIn))+1:length(dirIn);

[dim1, dim2, dim3] = size(imread(dirIn(1).name));


images_train = zeros(dim1, dim2,length(train));
images_test = zeros(dim1, dim2, length(test));
imagesSeg = zeros(dim1, dim2, length(test));




%For the first 50% of the images from the dataset, the background model is
%computed.

for i = train
    images_train(:,:,i) = rgb2gray(im2double(imread(dirIn(i).name)));
end


mu = zeros(dim1,dim2);
sigma = zeros(dim1,dim2);

for m = 1:dim1
    for n = 1:dim2
       
            mu(m,n)=mean(images_train(m,n,:));
            sigma(m,n)=std(images_train(m,n,:)); 
      
    end
end

%For the second 50% of the images from the dataset, the foreground is
%segmented
%  for alpha = 0.001:0.001:0.2
for i = test
    images_test(:,:,i-length(test)+1) = rgb2gray(im2double(imread(dirIn(i).name)));
    imagesSeg(:,:,i-length(test)+1) = abs(images_test(:,:,i-length(test)+1)-mu(:,:)) >= alpha*(2+sigma(:,:));
       
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
        TP_images(i) = pixelTP;
        FP_images(i) = pixelFP;
        FN_images(i) = pixelFN;
        TN_images(i) = pixelTN;
        
 end
    [pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
    metrics = [pixelTP,pixelFP,pixelFN,pixelTN];
    metrics2 = [pixelPrecision, pixelRecall,pixelFMeasure];
    
 
%  %Uncomment this lines so an analysis in relation to alpha is performed (remember to change the for sentence too)   
%     metrics(:,uint8(alpha*1000)) = [pixelTP,pixelFP,pixelFN,pixelTN];
%     metrics2(:,uint8(alpha*1000)) = [pixelPrecision, pixelRecall,pixelFMeasure];
% end
% 
% plot(alpha,metrics2(1,:),'r',alpha,metrics2(2,:),'g',alpha,metrics2(3,:),'b');
% title 'Precision Recall Fmeasure'
% xlabel('Alpha')
% ylabel('Value')
% legend('Precision','Recall','Fmeasure')