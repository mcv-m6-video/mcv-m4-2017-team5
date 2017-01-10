clear all
close all
clc
addpath(genpath('.'))
tic
%Directory where the masks of the different sets are placed

 directory_sequence = '../Database/Week02/highway/';
% directory_sequence = '../Database/Week02/fall/';
%directory_sequence = '../Database/Week02/traffic/';

directory_imagesIn = strcat(directory_sequence, 'input/');
directory_imagesGT = strcat(directory_sequence, 'groundtruth/');

dirIn = dir([directory_imagesIn '/*.jpg']);
dirGT = dir([directory_imagesGT '/*.png']);
percentage = 0.5;
alpha=0.1;

train = 1:floor(percentage*length(dirIn));
test = floor(percentage*length(dirIn)) + 1:length(dirIn);

[dim1, dim2, dim3] = size(imread(strcat(directory_imagesIn, dirIn(1).name)));


images_train = zeros(dim1, dim2,length(train));
images_test = zeros(dim1, dim2, length(test));
imagesSeg = zeros(dim1, dim2, length(test));




%For the first 50% of the images from the dataset, the background model is
%computed.

for i = train
%     images_train(:,:,i) = rgb2gray(im2double(imread(dirIn(i).name)));
    images_train(:,:,i) = rgb2gray(im2double(imread(strcat(directory_imagesIn, dirIn(i).name))));
end


mu = zeros(dim1,dim2);
sigma = zeros(dim1,dim2);

for m = 1:dim1
    for n = 1:dim2
       
            mu(m,n)=mean(images_train(m,n,:));
            sigma(m,n)=std(images_train(m,n,:)); 
      
    end
end
toc

%For the second 50% of the images from the dataset, the foreground is
%segmented
for alpha = 0.01:0.01:0.2
for i = test
    images_test(:,:,i-length(test)+1) = rgb2gray(im2double(imread(strcat(directory_imagesIn,dirIn(i).name))));
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
        TP_images(i-length(test)+1) = pixelTP;
        FP_images(i-length(test)+1) = pixelFP;
        FN_images(i-length(test)+1) = pixelFN;
        TN_images(i-length(test)+1) = pixelTN;
        
 end
    [pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
%     metrics = [pixelTP,pixelFP,pixelFN,pixelTN];
%     metrics2 = [pixelPrecision, pixelRecall,pixelFMeasure];
%     disp('termina')
 
 %Uncomment this lines so an analysis in relation to alpha is performed (remember to change the for sentence too)   
    metrics(:,uint8(alpha*100)) = [pixelTP,pixelFP,pixelFN,pixelTN];
    metrics2(:,uint8(alpha*100)) = [pixelPrecision, pixelRecall,pixelFMeasure];
end
alpha = 0.01:0.01:0.2;
plot(alpha,metrics2(1,:),'r',alpha,metrics2(2,:),'g',alpha,metrics2(3,:),'b');
title 'Precision Recall Fmeasure'
xlabel('Alpha')
ylabel('Value')
legend('Precision','Recall','Fmeasure')
figure,
plot(metrics2(2,:),metrics2(1,:))
title 'Precision Recall curve'
xlabel('Recall')
ylabel('Precision')
figure,
plot((metrics(2,:)./(metrics(2,:)+metrics(4,:))),metrics(1,:)./(metrics(1,:)+metrics(3,:)))
title 'ROC curve'
xlabel('FP ratio')
ylabel('TP ratio')
