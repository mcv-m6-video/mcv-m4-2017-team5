clear all; close all;
addpath(genpath('.'))

path_kitti = '../Database/Week01/Kitti/images/';
path_results_given_kitti = '../Results_given_week01/results_opticalflow_kitti/LKflow_';
path_ground_truth = '../Database/Week01/Kitti/gt_flow_nocc/';

%List of images to read
List_images = {'000045' '000157'};
tau = 3;
%Read gt and estimation of Flow
k = 1;
for k = 1:length(List_images)
    name_im = strcat(List_images{k}, '_10.png');
    Flow_est = flow_read(strcat(path_results_given_kitti, name_im));
    Flow_gt  = flow_read(strcat(path_ground_truth, name_im));
    
    [MSE, PEPN] = flow_error(Flow_gt, Flow_est, tau);
    
    Flow_err = flow_error_image(Flow_gt, Flow_est);
    
    
%     figure('Color', [1 1 1])
%     h1 = subplot(2, 1, 1);
%     p = get(h1, 'pos');
%     p(3) = p(3) + 0.05;
%     set(h1, 'pos', p);
%     imshow(flow_to_color(Flow_gt));
%     title('Optical flow ground-truth')
%     
%     h2 = subplot(2, 1, 2);
%     imshow(flow_to_color(Flow_est));
%     p = get(h2, 'pos');
%     p(3) = p(3) + 0.05;
%     set(h2, 'pos', p);
%     title('Optical flow estimation')
    
    figure('Color', [1 1 1])
    cols = error_colormap();
    cols = flipud(cols);
    imshow(Flow_err);
    colormap(cols(:,3:5));
    % p = get(h3, 'pos');
    % p(3) = p(3) + 0.04;
    % set(h3, 'pos', p);
%     title(strcat(sprintf('Percentage of erronous pixels: %.2f %%,', PEPN*100), sprintf(' Mean squared error: %.3f %', MSE)));
    compute_histogram = 0;
    labels = flow_error_histogram(Flow_gt, Flow_est, compute_histogram);
    c = colorbar('YTickLabel',labels);
    ylabel(c, 'Maximum Error at each pixel')
    
    figure('Color', [1 1 1])
    flow_error_histogram(Flow_gt, Flow_est, 1);
end
