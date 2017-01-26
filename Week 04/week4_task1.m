clear all; close all;
addpath(genpath('.'))

path_kitti = '../Database/Week01/Kitti/images/';

path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';

%List of images to read
List_images = {'000045' '000157'};
i = 2;
N = 16;
P = 16;
fwd_or_bwd = 'forward';

params  = compute_parameters_w4(path_kitti, path_ground_truth, List_images{i}, N, P, fwd_or_bwd);
%%

% Optical flow estimation
flow_estimation = block_matching( params );
fle = flow_estimation(:, :, 1);

% Optical flow evaluation
[ MSE, PEPN ] = evaluate_optical_flow( params, flow_estimation );
