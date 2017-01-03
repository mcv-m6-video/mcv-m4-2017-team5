clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed
directory_sequence = '../Database/Week02/highway/';
% directory_sequence = '../Database/Week02/fall/';
% directory_sequence = '../Database/Week02/traffic/';

directory_write = '../Results/week2/';
alpha = 0.01;
rho = 0.1;
percentage = 0.5;

param  = compute_parameters_w2(directory_sequence, directory_write, alpha, rho, percentage);


%%
%Computation_step
imagesSeg = recursive_gaussian( param );

%Evaluation step
[ ~, metrics2 ] = evaluate_model_adaptive( imagesSeg, param );



%%
%Grid search
min_alpha = 0.001;
step_alpha = 0.05;
max_alpha = 1;
alphas = min_alpha:step_alpha:max_alpha;

min_rho = 0;
step_rho = 0.01;
max_rho = 1;
rhos = min_rho:step_rho:max_rho;


dim1 = length(alphas);
dim2 = length(rhos);

directory_write = '../Results/week2/';
percentage = 0.5;

param  = compute_parameters_w2(directory_sequence, directory_write, 0, 0, percentage);

% 3 matrices with metrics for each pair of values of alpha and rho
%1: precision
%2:recall
%3:f-measure
metrics_search = zeros(dim1, dim2, 3);
for j = 1:dim2
    for i = 1:dim1
    
        sub2ind([dim1 dim2], i, j)
        param.alpha = alphas(i);
        param.rho = rhos(j);
    
        %Computation_step
        imagesSeg = recursive_gaussian( param );
    
        %Evaluation step
        [ ~, metrics2 ] = evaluate_model_adaptive( imagesSeg, param );
        metrics_search(i, j, 1) = metrics2(1);
        metrics_search(i, j, 2) = metrics2(2);
        metrics_search(i, j, 3) = metrics2(3);
    end
end
name_file = strcat(directory_write, 'Grid_search/grid_alpha_rho.mat' );
save(name_file, 'metrics_search', 'alphas', 'rhos')
%%
plot( shiftdim(metrics_search(1, 1, :)),shiftdim(metrics_search(1, 2, :)), 'r')
%, alphas, shiftdim(metrics_search(1, 2,:)), 'g', alphas, shiftdim(metrics_search(1, 3,:)), 'b');
title 'Precision Recall'
xlabel('Alpha')
ylabel('Value')
legend('Precision','Recall','Fmeasure')