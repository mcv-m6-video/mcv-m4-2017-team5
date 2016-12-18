clear all; close all;
addpath(genpath('.'))

path_kitti = '../Database/Kitti/images/';
path_results_given_kitti = '../Results_given_week01/results_opticalflow_kitti/LKflow_';
path_ground_truth = '../Database/Kitti/gt_flow_nocc/';

%List of images to read
List_images = {'000045' '000157'};

%Read gt and estimation of Flow
i = 1;
%  for i = 1:length(List_images)
name_im = strcat(List_images{i}, '_10.png');
Flow_estimation = flow_read(strcat(path_results_given_kitti, name_im));
Flow_gt  = flow_read(strcat(path_ground_truth, name_im));

%  end
