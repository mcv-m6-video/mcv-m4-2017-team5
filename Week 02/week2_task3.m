% clear all
% close all
% clc
addpath(genpath('.'))


%Directory where the masks of the different sets are placed

% directory_sequence = '../Database/Week02/highway/';
% directory_sequence = '../Database/Week02/fall/';
directory_sequence = '../Database/Week02/traffic/';

directory_imagesIn = strcat(directory_sequence, 'input/');
dirIn = dir([directory_imagesIn '/*.jpg']);
ext='.jpg';
directory_imagesGT = strcat(directory_sequence, 'groundtruth/');
dirGT = dir([directory_imagesGT '/*.png']);

path_results = '../Week 02/';
if exist([path_results 'ResultsTask3']) == 0
	mkdir([path_results 'ResultsTask3/highway'])
    mkdir([path_results 'ResultsTask3/fall'])
    mkdir([path_results 'ResultsTask3/traffic'])
end

[dim1, dim2, dim3] = size(imread(strcat(directory_imagesIn, dirIn(1).name)));
imagesSeg = zeros(dim1, dim2, length(dirIn));

if strcmp(directory_sequence,'../Database/Week02/highway/')
    direc = 1;
    T1 = 1050;
    T2 = 1350;
elseif strcmp(directory_sequence,'../Database/Week02/fall/')
    direc = 2;
    T1 = 1460;
    T2 = 1560;
else
    direc = 3;
    T1 = 950;
    T2 = 1050;
end

K = 5;
Rho = 0.000000000000000000000000000007; % if tend to 0 -> long memory %0.05
Threshold = 2000; %220 
THFG = 0.9758; %0.85
video='traffic';

filename = 'Video_traffic.gif';

[Sequence] = MultG_fun(Threshold,T1,T2,K,Rho,THFG,video);
    
%Evaluation step
    TP_images = zeros(length(Sequence), 1);
    FP_images = zeros(length(Sequence), 1);
    FN_images = zeros(length(Sequence), 1);
    TN_images = zeros(length(Sequence), 1);

for i=1:length(dirIn)
    if direc==1
       imwrite(Sequence(:,:,i),[path_results 'ResultsTask3/highway' dirIn(i).name ]);
       scene = imread(strcat(directory_imagesIn,dirIn(i).name));
       imageGT = imread(strcat(directory_imagesGT,dirGT(i).name));
       [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(Sequence(:,:,i), imageGT);
        TP_images(i) = pixelTP;
        FP_images(i) = pixelFP;
        FN_images(i) = pixelFN;
        TN_images(i) = pixelTN;
        FMeasure = (2*TP_images)./(2*TP_images + FN_images + FP_images);
        
        subplot(221);
        imshow(scene);
        subplot(222),
        imshow(Sequence(:,:,i),[]);
        subplot(2,2,[3 4]);
        plot(1:length(Sequence),FMeasure);
        %axis([0 200 0 1])

        frame = getframe(gcf);
        im=frame2im(frame);
        [imind,cm]=rgb2ind(im,256);
        
        % On the first loop, create the file. In subsequent loops, append.
         if i==1
             imwrite(imind,cm,filename,'gif','DelayTime',0,'Loopcount',inf);
         else
            imwrite(imind,cm,filename,'gif','DelayTime',0,'WriteMode','append');
         end
         
    elseif direc ==2
       imwrite(Sequence(:,:,i),[path_results 'ResultsTask3/fall' dirIn(i).name ]);
       scene = imread(strcat(directory_imagesIn,dirIn(i).name));
       imageGT = imread(strcat(directory_imagesGT,dirGT(i).name));
       [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(Sequence(:,:,i), imageGT);
        TP_images(i) = pixelTP;
        FP_images(i) = pixelFP;
        FN_images(i) = pixelFN;
        TN_images(i) = pixelTN;
        FMeasure = (2*TP_images)./(2*TP_images + FN_images + FP_images);
        
        subplot(221);
        imshow(scene);
        subplot(222),
        imshow(Sequence(:,:,i),[]);
        subplot(2,2,[3 4]);
        plot(1:length(dirIn),FMeasure);
        %axis([0 200 0 1])

        frame = getframe(gcf);
        im=frame2im(frame);
        [imind,cm]=rgb2ind(im,256);
        
        % On the first loop, create the file. In subsequent loops, append.
         if i==1
             imwrite(imind,cm,filename,'gif','DelayTime',0,'Loopcount',inf);
         else
            imwrite(imind,cm,filename,'gif','DelayTime',0,'WriteMode','append');
         end
         
    else
       imwrite(Sequence(:,:,i),[path_results 'ResultsTask3/traffic' dirIn(i).name ]);
       scene = imread(strcat(directory_imagesIn,dirIn(i).name));
       imageGT = imread(strcat(directory_imagesGT,dirGT(i).name));
       [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(Sequence(:,:,i), imageGT);
        TP_images(i) = pixelTP;
        FP_images(i) = pixelFP;
        FN_images(i) = pixelFN;
        TN_images(i) = pixelTN;
       FMeasure = (2*TP_images)./(2*TP_images + FN_images + FP_images);
        
        subplot(221);
        imshow(scene);
        subplot(222),
        imshow(Sequence(:,:,i),[]);
        subplot(2,2,[3 4]);
        plot(1:320,FMeasure);
        %axis([0 200 0 1])

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

[pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
metrics = [pixelTP,pixelFP,pixelFN,pixelTN];
metrics2 = [pixelPrecision, pixelRecall,pixelFMeasure];

%Input :
% Threshold : Threshold to assign pixels to a Gaussian model 
% Rho : Adaptation constant
% K : Number of Gaussian in the mixture
% THFG : % of weights corresponding to foreground objects
% T1 : Frame in the beginning
% T2 : Endng Frame
% video : 'highway', 'fall' or 'traffic'. The folder corresponding to these
% video have to be in the same folder than this function.





