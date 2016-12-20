clear all
close all
clc
addpath(genpath('.'))

% Directory where the masks of the different sets are placed
directory_imagesGT = '../Database/highway/groundtruth/';
directory_imagesA = '../Results_given_week01/results_highway_changedetection/test_A/';
directory_imagesB = '../Results_given_week01/results_highway_changedetection/test_B/';
dirGT = dir([directory_imagesGT '/*.png']);
dirA = dir([directory_imagesA '/*.png']);
dirB = dir([directory_imagesB '/*.png']);


metrics = zeros(4,2);
metrics2 = zeros(3,2);
desync_max = 25;

TP_images = zeros(length(dirGT), 1, desync_max + 1);
FP_images = zeros(length(dirGT), 1, desync_max + 1);
FN_images = zeros(length(dirGT), 1, desync_max + 1);
TN_images = zeros(length(dirGT), 1, desync_max + 1);

for desync = 0:desync_max
    for test = 1:2
        switch test
            case 1
                direct = dirA;
                directory_images = directory_imagesA;
            case 2
                direct = dirB;
                directory_images = directory_imagesB;
        end
        for i = desync + 1:length(direct) - desync
            
            % Compute TP, FP, FN and TN for each image and save it
            imageGT = imread(strcat(directory_imagesGT, dirGT(i).name));
            image = imread(strcat(directory_images, direct(i - (desync)).name));
            [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(image, imageGT);
            TP_images(i, test, desync + 1) = pixelTP;
            FP_images(i, test, desync + 1) = pixelFP;
            FN_images(i, test, desync + 1) = pixelFN;
            TN_images(i, test, desync + 1) = pixelTN;
            
        end
        %     [pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
        %     metrics(:,test)= [pixelTP, pixelFP, pixelFN, pixelTN];
        %     metrics2(:,test) = [pixelPrecision, pixelRecall, pixelFMeasure];
    end
end


%Fmeasure for each image, test and desync
FMeasure = (2*TP_images)./(2*TP_images + FN_images + FP_images);
FMeasure(isnan(FMeasure)) = 0;

%Fmeasure for each sequence, test and desync
TP_sequence = sum(TP_images, 1);
FN_sequence = sum(FN_images, 1);
FP_sequence = sum(FP_images, 1);
FM_sequence = (2*TP_sequence)./(2*TP_sequence + FN_sequence + FP_sequence);

%%
%Plots for test B
%Plot: accumulative Fmeasure. One curve per desync
desyncs_plot = [0 10 20 25];
colors_plot = {'red', 'blue', 'green', 'magenta'};
figure
for i = 1:length(desyncs_plot)
    plot(1:200, FMeasure(:, 2, desyncs_plot(i) + 1), colors_plot{i})
    hold on
end
hold off
%Plot: Global Fmeasure. One point per desync, one curve for all
FM_plot = shiftdim(FM_sequence(1, 2, :));

figure
plot(0:desync_max, FM_plot, 'red')


% subplot(121),
% plot(1:200,FMeasure);
% title 'Fmeasure non Accumulative'
% xlabel('Frame')
% ylabel('Value')
%
% subplot(122),
% plot(1:200,cumFM);
% title 'Fmeasure Accumulative'
% xlabel('Frame')
% ylabel('Value')
%
% figure,
% subplot(121),
% plot(1:200,cumTP,'r',1:200,cumTotalP,'b')
% legend('TP','TP+FP')
% xlabel('Frame')
% ylabel('Pixels')
% title 'Accumulative'
%
% subplot(122),
% plot(1:200,TP_images,'r',1:200,TP_images+FP_images,'b')
% legend('TP','TP+FP')
% xlabel('Frame')
% ylabel('Pixels')
% title 'Non accumulative'






