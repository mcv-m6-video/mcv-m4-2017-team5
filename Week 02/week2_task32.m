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
    T1 = 1050;
    T2 = 1350;
    video='highway';
elseif strcmp(directory_sequence,'../Database/Week02/fall/')
    T1 = 1460;
    T2 = 1560;
    video='fall';
else
    T1 = 950;
    T2 = 1050;
    video='traffic';
end

K = 3;
Rho = 0.000001;
% Rho = 0.0000000000000000000000000007; % if tend to 0 -> long memory %0.05
Threshold = 2000; %220 
THFG = 0.9758; %0.85

filename = 'Video_highway.gif';

[Sequence] = MultG_fun(Threshold,T1,T2,K,Rho,THFG,video);
    
[TP_images,FP_images,FN_images,TN_images] = Evaluation(Sequence,path_results,directory_imagesIn,dirIn,directory_imagesGT,dirGT,filename,video);

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





