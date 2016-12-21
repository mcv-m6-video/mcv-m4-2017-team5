clear all; close all;

path_kitti = '../Database/Kitti/images';
path_results_given_kitti = '../Results_given_week01/results_opticalflow_kitti';
path_ground_truth = '../Database/Kitti/gt_flow_nocc';

gt_flow_files=dir(strcat(path_ground_truth,'/*.png'));
est_flow_files=dir(strcat(path_results_given_kitti,'/*.png'));


for i=1:length(gt_flow_files)
    Flow_est = flow_read(strcat(path_results_given_kitti,filesep, est_flow_files(i).name));
    Flow_gt  = flow_read(strcat(path_ground_truth,filesep, gt_flow_files(i).name));

    Image=imread(strcat(path_kitti,filesep,gt_flow_files(i).name));

    rSize=10;%Region size
    scale=20;

    plot_optical_flow (Image,Flow_gt,rSize,scale,strcat('of_',gt_flow_files(i).name));%Plot ground truth
    title('Optical flow of ground truth');
    plot_optical_flow (Image,Flow_est,rSize,scale,strcat('of_',est_flow_files(i).name));%Plot estimated flow
    title('Optical flow of estimation');
    
    %Mean optical flow
    plot_mean_optical_flow (Image,Flow_gt,rSize,scale,strcat('mof_',gt_flow_files(i).name));
    title('Mean optical flow of ground truth');
    plot_mean_optical_flow (Image,Flow_est,rSize,scale,strcat('mof_',est_flow_files(i).name));
    title('Mean optical flow of estimation');
end