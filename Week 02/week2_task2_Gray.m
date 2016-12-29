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
%Grid_search
alphas = 0.001:0.005:0.2;
rhos = 0:0.01:1;
[Alpha, Rho] = meshgrid(alphas, rhos);
[dim1, dim2] = size(Alpha);

directory_write = '../Results/week2/';
alpha = 0;
rho = 0;
percentage = 0.5;

param  = compute_parameters_w2(directory_sequence, directory_write, alpha, rho, percentage);
metrics_search = zeros(1, 3, dim1*dim2);
for i = 1:dim1*dim2
    param.alpha = Alpha(i);
    param.rho = Rho(i);
    
    %Computation_step
    imagesSeg = recursive_gaussian( param );
    
    %Evaluation step
    [ ~, metrics2 ] = evaluate_model_adaptive( imagesSeg, param );
    metrics_search(:, :, i) = metrics2;
end

%%
plot( shiftdim(metrics_search(1, 1, :)),shiftdim(metrics_search(1, 2, :)), 'r')
%, alphas, shiftdim(metrics_search(1, 2,:)), 'g', alphas, shiftdim(metrics_search(1, 3,:)), 'b');
title 'Precision Recall'
xlabel('Alpha')
ylabel('Value')
legend('Precision','Recall','Fmeasure')