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
%Plots for test A
test = 1;
%Plot: accumulative Fmeasure. One curve per desync
desyncs_plot = [0 10 20 25];
colors_plot = {'red', 'blue', 'green', 'magenta'};
figure('Color', [1 1 1])
for i = 1:length(desyncs_plot)
    plot(1:200, FMeasure(:, test, desyncs_plot(i) + 1), colors_plot{i})
    hold on
end
hold off
legend('Without delay','Delay of 10 frames','Delay of 20 frames','Delay of 25 frames')
xlabel('Frame number')
ylabel('F1 Measure')
title 'Forward de-synchronized results frame by frame with test A'
%Plot: Global Fmeasure. One point per desync, one curve for all
FM_plot = shiftdim(FM_sequence(1, test, :));

figure('Color', [1 1 1])
plot(0:desync_max, FM_plot, 'red')
title 'Forward de-synchronized results for sequence with test A'
xlabel('Frames of delay')
ylabel('F1 Measure')

%test B
test = 2;
%Plot: accumulative Fmeasure. One curve per desync
desyncs_plot = [0 10 20 25];
colors_plot = {'red', 'blue', 'green', 'magenta'};
figure('Color', [1 1 1])
for i = 1:length(desyncs_plot)
    plot(1:200, FMeasure(:, test, desyncs_plot(i) + 1), colors_plot{i})
    hold on
end
hold off
legend('Without delay','Delay of 10 frames','Delay of 20 frames','Delay of 25 frames')
xlabel('Frame number')
ylabel('F1 Measure')
title 'Forward de-synchronized results frame by frame with test B'
%Plot: Global Fmeasure. One point per desync, one curve for all
FM_plot = shiftdim(FM_sequence(1, test, :));

figure('Color', [1 1 1])
plot(0:desync_max, FM_plot, 'red')
title 'Forward de-synchronized results for sequence with test B'
xlabel('Frames of delay')
ylabel('F1 Measure')