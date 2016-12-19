clear all; close all;
addpath(genpath('.'))

path_kitti = '../Database/Kitti/images/';
path_results_given_kitti = '../Results_given_week01/results_opticalflow_kitti/LKflow_';
path_ground_truth = '../Database/Kitti/gt_flow_nocc/';

%List of images to read
List_images = {'000045' '000157'};
tau = 3;
%Read gt and estimation of Flow
k = 1;
%  for i = 1:length(List_images)
name_im = strcat(List_images{k}, '_10.png');
Flow_est = flow_read(strcat(path_results_given_kitti, name_im));
Flow_gt  = flow_read(strcat(path_ground_truth, name_im));

[MSE, PEPN] = flow_error (Flow_gt, Flow_est, tau);

Flow_err = flow_error_image(Flow_gt, Flow_est);
figure, imshow([flow_to_color([Flow_est; Flow_gt]); Flow_err]);
title(sprintf('Error: %.2f %%', PEPN*100));
figure, flow_error_histogram(Flow_gt,Flow_est);    
%  end
