clear all; close all;
addpath(genpath('.'))

path_kitti = '../Database/Week01/Kitti/images/';
path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';

%List of images to read
List_images = {'000045' '000157'};
i = 1;
N = 16;
P = 16;
fwd_or_bwd = 'forward';

params  = compute_parameters_w4(path_kitti, path_ground_truth, List_images{i}, N, P, fwd_or_bwd);
%%

% Optical flow estimation
flow_estimation = block_matching( params );

% Optical flow evaluation
[ MSE, PEPN ] = evaluate_optical_flow( params, flow_estimation );
%% 
comp_im = compensated_image( params, flow_estimation );
imshow(uint8(comp_im))

%%
% % Grid_search image 1 forward
% path_kitti = '../Database/Week01/Kitti/images/';
% path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';
% 
% %List of images to read
% List_images = {'000045' '000157'};
% i = 1;
% fwd_or_bwd = 'forward';
% 
% params  = compute_parameters_w4(path_kitti, path_ground_truth, List_images{i}, 0, 0, fwd_or_bwd);
% 
% Ns = 4:4:60;
% Ps = 4:4:56;
% metrics_forward_1 = zeros(length(Ns), length(Ps), 2);
% n = 1;
% for i = 1:length(Ns)
%     for j = 1:length(Ps)
%         display(n)
%         params.N = Ns(i);
%         params.P = Ps(j);
%         % Optical flow estimation
%         flow_estimation = block_matching( params );
%         
%         % Optical flow evaluation
%         [ MSE, PEPN ] = evaluate_optical_flow( params, flow_estimation );
%         
%         metrics_forward_1(i, j, 1) = MSE;
%         metrics_forward_1(i, j, 2) = PEPN;
%          n = n + 1;
%     end
% end
% if ~exist('../Results/week4/Grid_search/', 'dir')
%     mkdir('../Results/week4/Grid_search/');
% end
% name_file = strcat('../Results/week4/Grid_search/Grid_search_P_N_forward_01.mat' );
% save(name_file, 'metrics_forward_1', 'Ps', 'Ns')


%%
% % Grid_search image 2 forward
% path_kitti = '../Database/Week01/Kitti/images/';
% path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';
% 
% %List of images to read
% List_images = {'000045' '000157'};
% i = 2;
% fwd_or_bwd = 'forward';
% 
% params  = compute_parameters_w4(path_kitti, path_ground_truth, List_images{i}, 0, 0, fwd_or_bwd);
% 
% Ns = 4:4:60;
% Ps = 4:4:56;
% metrics_forward_2 = zeros(length(Ns), length(Ps), 2);
% n = 1;
% for i = 1:length(Ns)
%     for j = 1:length(Ps)
%         display(n)
%         params.N = Ns(i);
%         params.P = Ps(j);
%         % Optical flow estimation
%         flow_estimation = block_matching( params );
%         
%         % Optical flow evaluation
%         [ MSE, PEPN ] = evaluate_optical_flow( params, flow_estimation );
%         
%         metrics_forward_2(i, j, 1) = MSE;
%         metrics_forward_2(i, j, 2) = PEPN;
%          n = n + 1;
%     end
% end
% if ~exist('../Results/week4/Grid_search/', 'dir')
%     mkdir('../Results/week4/Grid_search/');
% end
% name_file = strcat('../Results/week4/Grid_search/Grid_search_P_N_forward_02.mat' );
% save(name_file, 'metrics_forward_2', 'Ps', 'Ns')


%%
% % Grid_search image 1 forward
% path_kitti = '../Database/Week01/Kitti/images/';
% path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';
% 
% %List of images to read
% List_images = {'000045' '000157'};
% i = 1;
% fwd_or_bwd = 'backward';
% 
% params  = compute_parameters_w4(path_kitti, path_ground_truth, List_images{i}, 0, 0, fwd_or_bwd);
% 
% Ns = 4:4:60;
% Ps = 4:4:56;
% metrics_backward_1 = zeros(length(Ns), length(Ps), 2);
% n = 1;
% for i = 1:length(Ns)
%     for j = 1:length(Ps)
%         display(n)
%         params.N = Ns(i);
%         params.P = Ps(j);
%         % Optical flow estimation
%         flow_estimation = block_matching( params );
%         
%         % Optical flow evaluation
%         [ MSE, PEPN ] = evaluate_optical_flow( params, flow_estimation );
%         
%         metrics_backward_1(i, j, 1) = MSE;
%         metrics_backward_1(i, j, 2) = PEPN;
%          n = n + 1;
%     end
% end
% if ~exist('../Results/week4/Grid_search/', 'dir')
%     mkdir('../Results/week4/Grid_search/');
% end
% name_file = strcat('../Results/week4/Grid_search/Grid_search_P_N_backward_01.mat' );
% save(name_file, 'metrics_backward_1', 'Ps', 'Ns')


% %%
% % Grid_search image 2 backward
% path_kitti = '../Database/Week01/Kitti/images/';
% path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';
% 
% %List of images to read
% List_images = {'000045' '000157'};
% i = 2;
% fwd_or_bwd = 'backward';
% 
% params  = compute_parameters_w4(path_kitti, path_ground_truth, List_images{i}, 0, 0, fwd_or_bwd);
% 
% Ns = 4:4:60;
% Ps = 4:4:56;
% metrics_backward_2 = zeros(length(Ns), length(Ps), 2);
% n = 1;
% for i = 1:length(Ns)
%     for j = 1:length(Ps)
%         display(n)
%         params.N = Ns(i);
%         params.P = Ps(j);
%         % Optical flow estimation
%         flow_estimation = block_matching( params );
%         
%         % Optical flow evaluation
%         [ MSE, PEPN ] = evaluate_optical_flow( params, flow_estimation );
%         
%         metrics_backward_2(i, j, 1) = MSE;
%         metrics_backward_2(i, j, 2) = PEPN;
%          n = n + 1;
%     end
% end
% if ~exist('../Results/week4/Grid_search/', 'dir')
%     mkdir('../Results/week4/Grid_search/');
% end
% name_file = strcat('../Results/week4/Grid_search/Grid_search_P_N_backward_02.mat' );
% save(name_file, 'metrics_backward_2', 'Ps', 'Ns')