clear all; close all;
addpath(genpath('.'))

name_file = strcat('../Results/week4/Grid_search/Grid_search_P_N_forward_01.mat' );
load(name_file)
name_file = strcat('../Results/week4/Grid_search/Grid_search_P_N_forward_02.mat' );
load(name_file)
name_file = strcat('../Results/week4/Grid_search/Grid_search_P_N_backward_01.mat' );
load(name_file)
name_file = strcat('../Results/week4/Grid_search/Grid_search_P_N_backward_02.mat' );
load(name_file)
%%
PEPN_forward_1 = metrics_forward_1(:, :, 2);
min_PEPN_value = min(min(PEPN_forward_1));
min_PEPN_idx = find(PEPN_forward_1 == (min(min(PEPN_forward_1))));
[N_min, P_min] = ind2sub(size(PEPN_forward_1), min_PEPN_idx);

figure('Color', 'white'),
[X, Y] = meshgrid(Ps, Ns);
surf (X, Y, PEPN_forward_1)



hold on
s = 150;
c = 'red';
scatter3( Ps(P_min), Ns(N_min), PEPN_forward_1(N_min, P_min),s,c, 'filled')
text(Ps(P_min), Ns(N_min),PEPN_forward_1(N_min, P_min) - 0.05, ...
    strcat('Minimum value of PEPN:   ', num2str(min_PEPN_value)),...
    'FontWeight', 'bold')

xlabel('P','FontWeight', 'bold')
ylabel('N','FontWeight', 'bold')
zlabel('PEPN','FontWeight', 'bold')
title('Exhaustive search of PEPN in sequence 45','FontWeight', 'bold')
% axis square

%%
PEPN_forward_2 = metrics_forward_2(:, :, 2);
figure('Color', 'white'),
[X, Y] = meshgrid(Ps, Ns);
surf (X, Y, PEPN_forward_2)

min_PEPN_value = min(min(PEPN_forward_2));
min_PEPN_idx = find(PEPN_forward_2 == (min(min(PEPN_forward_2))));
[N_min, P_min] = ind2sub(size(PEPN_forward_2), min_PEPN_idx);

hold on
s = 120;
c = 'red';
scatter3( Ps(P_min), Ns(N_min), PEPN_forward_2(N_min, P_min),s,c, 'filled')
text(Ps(P_min), Ns(N_min),PEPN_forward_2(N_min, P_min) - 0.05, ...
    strcat('Minimum value of PEPN:   ', num2str(min_PEPN_value)),...
    'FontWeight', 'bold')

xlabel('P','FontWeight', 'bold')
ylabel('N','FontWeight', 'bold')
zlabel('PEPN','FontWeight', 'bold')
title('Exhaustive search of PEPN in sequence 157','FontWeight', 'bold')
% axis square

%%
path_kitti = '../Database/Week01/Kitti/images/';
path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';

%List of images to read
List_images = {'000045' '000157'};
i = 1;
PEPN_forward_1 = metrics_forward_1(:, :, 2);
min_PEPN_idx = find(PEPN_forward_1 == (min(min(PEPN_forward_1))));
[N_min, P_min] = ind2sub(size(PEPN_forward_1), min_PEPN_idx);
N = Ns(N_min);
P = Ps(P_min);
fwd_or_bwd = 'forward';

params  = compute_parameters_w4(path_kitti, path_ground_truth, List_images{i}, N, P, fwd_or_bwd);


% Optical flow estimation
flow_estimation = block_matching( params );


comp_im = compensated_image( params, flow_estimation );
imshow(uint8(comp_im))


imwrite(uint8(comp_im), '../Results/week4/Compensated_image_kitti_045.png')
%%
path_kitti = '../Database/Week01/Kitti/images/';
path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';

%List of images to read
List_images = {'000045' '000157'};
i = 2;
PEPN_forward_2 = metrics_forward_2(:, :, 2);
min_PEPN_idx = find(PEPN_forward_2 == (min(min(PEPN_forward_2))));
[N_min, P_min] = ind2sub(size(PEPN_forward_2), min_PEPN_idx);
N = Ns(N_min);
P = Ps(P_min);
fwd_or_bwd = 'forward';

params  = compute_parameters_w4(path_kitti, path_ground_truth, List_images{i}, N, P, fwd_or_bwd);

% Optical flow estimation
flow_estimation = block_matching( params );

%Compensated image
comp_im = compensated_image( params, flow_estimation );
imshow(uint8(comp_im))
imwrite(uint8(comp_im), '../Results/week4/Compensated_image_kitti_157.png')
%%
path_kitti = '../Database/Week01/Kitti/images/';
path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';

%List of images to read
List_images = {'000045' '000157'};
i = 1;
PEPN_forward_1 = metrics_forward_1(:, :, 2);
min_PEPN_idx = find(PEPN_forward_1 == (min(min(PEPN_forward_1))));
[N_min, P_min] = ind2sub(size(PEPN_forward_1), min_PEPN_idx);
N = Ns(N_min);
P = Ps(P_min);
fwd_or_bwd = 'forward';

params  = compute_parameters_w4(path_kitti, path_ground_truth, List_images{i}, N, P, fwd_or_bwd);


% Optical flow estimation
Flow_est = block_matching( params );

gt_flow_files=dir(strcat(path_ground_truth,'/*.png'));
path_results_given_kitti = '../Results_given_week01/results_opticalflow_kitti';
est_flow_files=dir(strcat(path_results_given_kitti,'/*.png'));

Flow_gt  = flow_read(strcat(path_ground_truth,filesep, gt_flow_files(i).name));
Flow_est(:, :, 3) = Flow_gt(:, :, 3);
Image = imread(strcat(path_kitti,filesep,gt_flow_files(i).name));

rSize = 20;%Region size
scale = 20;


plot_optical_flow(Image, Flow_est, rSize, scale, strcat('of_',est_flow_files(i).name));%Plot estimated flow
% title('Optical flow of estimation');

%Mean optical flow
plot_mean_optical_flow(Image, Flow_est, rSize, scale, strcat('mof_', est_flow_files(i).name));
title('Mean optical flow of estimation');


%%
%List of images to read
List_images = {'000045' '000157'};
i = 2;
PEPN_forward_2 = metrics_forward_2(:, :, 2);
min_PEPN_idx = find(PEPN_forward_2 == (min(min(PEPN_forward_2))));
[N_min, P_min] = ind2sub(size(PEPN_forward_2), min_PEPN_idx);
N = Ns(N_min);
P = Ps(P_min);
fwd_or_bwd = 'forward';

params  = compute_parameters_w4(path_kitti, path_ground_truth, List_images{i}, N, P, fwd_or_bwd);

% Optical flow estimation
Flow_est = block_matching( params );

gt_flow_files=dir(strcat(path_ground_truth,'/*.png'));
path_results_given_kitti = '../Results_given_week01/results_opticalflow_kitti';
est_flow_files=dir(strcat(path_results_given_kitti,'/*.png'));

Flow_gt  = flow_read(strcat(path_ground_truth,filesep, gt_flow_files(i).name));
Flow_est(:, :, 3) = Flow_gt(:, :, 3);
Image = imread(strcat(path_kitti,filesep,gt_flow_files(i).name));

rSize = 20;%Region size
scale = 20;


plot_optical_flow(Image, Flow_est, rSize, scale, strcat('of_',est_flow_files(i).name));%Plot estimated flow
% title('Optical flow of estimation');

%Mean optical flow
plot_mean_optical_flow(Image, Flow_est, rSize, scale, strcat('mof_', est_flow_files(i).name));
title('Mean optical flow of estimation');
