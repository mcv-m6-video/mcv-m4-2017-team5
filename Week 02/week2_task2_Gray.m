clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed
% sequence = 'highway/';
sequence = 'fall/';
% sequence = 'traffic/';

directory_sequence = strcat('../Database/Week02/', sequence);

directory_write = strcat('../Results/week2/', sequence);
directory_write_grid = '../Results/week2/';
alpha = 0.1510;
rho = 0.0900;    
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
seq = strsplit(sequence, '/');
name_file = strcat(directory_write_grid, 'Grid_search/', seq{1},'_grid_alpha_rho.mat' );
save(name_file, 'metrics_search', 'alphas', 'rhos')
%%
seq = strsplit(sequence, '/');
name_file = strcat(directory_write_grid, 'Grid_search/', seq{1},'_grid_alpha_rho.mat' );
load(name_file)
precision = shiftdim(metrics_search(:, :, 1));
recall = shiftdim(metrics_search(:, :, 2));
fmeasure = shiftdim(metrics_search(:, :, 3));
[Alpha, Rho] = meshgrid(rhos, alphas);
%Plot surfaces
figure('units','normalized','outerposition',[0 0 1 1]), surf(Alpha, Rho, precision)
axis square
% figure, surf(Alpha, Rho, recall)
% figure, surf(Alpha, Rho, fmeasure)

%%
max_fm_idx = find(fmeasure == (max(max(fmeasure))));


[i_max, j_max] = ind2sub(size(fmeasure), max_fm);
max_fm = fmeasure(i_max, j_max);
% pixelPrecision, pixelRecall, pixelFMeasure]
% plot( shiftdim(metrics_search(1, 1, :)),shiftdim(metrics_search(1, 2, :)), 'r')
% %, alphas, shiftdim(metrics_search(1, 2,:)), 'g', alphas, shiftdim(metrics_search(1, 3,:)), 'b');
% title 'Precision Recall'
% xlabel('Alpha')
% ylabel('Value')
% legend('Precision','Recall','Fmeasure')