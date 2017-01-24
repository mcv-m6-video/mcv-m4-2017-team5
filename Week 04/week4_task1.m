clear all; close all;
addpath(genpath('.'))

path_kitti = '../Database/Kitti/images/';
path_results_given_kitti = '../Results_given_week01/results_opticalflow_kitti/LKflow_';
path_ground_truth = '../Database/Kitti/gt_flow_nocc/';

%List of images to read
List_images = {'000045' '000157'};
i = 1;

%%
