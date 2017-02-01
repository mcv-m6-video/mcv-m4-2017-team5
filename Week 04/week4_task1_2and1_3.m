clear all; close all;
addpath(genpath('.'))

path_kitti = '../Database/Week01/Kitti/images/';
path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';
tau = 3;

Results = [];

% List of images to read
for list=1:2
    if list==1
        List_images = {'000045_10' '000045_11' '000045'};
    else
        T_Results_list1=T_Results;
        clearvars Flow_est Table T_Results
        List_images = {'000157_10' '000157_11'  '000157'};
    end

    % Method used in the estimation of optical flow
    for flow_obj=1:4
        switch flow_obj
            case 1
                opticFlow = opticalFlowLK();
                method = 'Lucas-Kanade';      
            case 2
                opticFlow = opticalFlowHS('Smoothness',1,'MaxIteration',100,'VelocityDifference',0);
                method = 'Horn-Schunck';
            case 3
                opticFlow = opticalFlowLKDoG('NumFrames',3);
                method = 'Lucas-Kanade derivative of Gaussian';
            case 4
                opticFlow = opticalFlowFarneback();
                method = 'Farneback';
        end

        %Estimate and display the optical flow of objects.
        for i=1:length(List_images)-1
            name_im = strcat(List_images{i}, '.png');
            frame=imread(strcat(path_kitti, name_im));
            Flow_gt  = flow_read(strcat(path_ground_truth, List_images{1}, '.png'));

            flow = estimateFlow(opticFlow,frame);    

            Flow_est(:,:,1) = flow.Vx;
            Flow_est(:,:,2) = flow.Vy;

            [MSE, PEPN] = flow_error (Flow_gt, Flow_est, tau);
        
            figure
            imshow(frame)
            hold on
            plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
            hold off
        end
        
        Results = [List_images(3) MSE PEPN];
        
        if  flow_obj==1
            T_Results = array2table(Results,'RowNames', {method} ,'VariableNames',{'Images' 'MSE' 'PEPN'});
        else
            T = array2table(Results,'RowNames', {method} ,'VariableNames',{'Images' 'MSE' 'PEPN'});
            T_Results = [T_Results;T];
        end 
    end
end