%Computes precision/recall curve for a range of alpha values, as well as
%the AUC value

clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed
%sequence = 'highway/';
%sequence = 'fall/';
%sequence = 'traffic/';

sequences={'highway/','fall/','traffic/'};
intervalpha = 0:0.02:0.28;%Alpha values

percentage = 0.5;
cnn = 4;%connectivity for imfill

%Plot Precision-Recall
figure();
xlabel('Recall')
ylabel('Precision')

AUCs=[];
for i = 1:length(sequences)%For each sequence
    sequence = sequences{i};
    
    switch sequence
        case 'highway/'
            process_type = 3;
            %alpha = 0.101;
            rho = 0.04;
            P= 60;%pixels used for bwareaopen
            plotcolor='g';
        case 'fall/'
            process_type = 4;
            %alpha = 0.101;
            rho = 0.18;
            P=700;
            plotcolor='r';
        case 'traffic/'
            process_type = 5;
            %alpha = 0.151;
            rho = 0.09;
            P=30;
            plotcolor='b';
    end
    directory_sequence = strcat('../Database/Week02/', sequence);
    directory_write = strcat('../Results/week3/', sequence);

    contador = 0;
    for alpha = intervalpha
        contador = contador + 1;
        param  = compute_parameters_w3(sequence, directory_write, alpha, rho, percentage, 0);
        %Computation_step
        imagesSeg = recursive_gaussian( param );
        %Morphological step
        imagesSegMorph = morphological(imagesSeg,process_type, P);
        %Evaluation step
        [ metrics(:,contador), metrics2(:,contador) ] = evaluate_model_adaptive( imagesSegMorph, param );
    end
    
    %Plot Precision-Recall
    plot(metrics2(2,:),metrics2(1,:),plotcolor)
    hold on;
    %AUC
    auc = areaundercurve(metrics2(2,:),metrics2(1,:));
    
    disp(strcat('AUC for ',sequence));
    disp(auc);
    AUCs=[AUCs,auc];
end
legend(strcat('highway (AUC= ',num2str(AUCs(1)),')'),strcat('fall (AUC= ',num2str(AUCs(2)),')'),strcat('traffic (AUC= ',num2str(AUCs(3)),')'))
legend('Location','southwest')
legend('boxoff')
title('Precision-Recall curve');
