clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed
sequence = 'highway/';
% sequence = 'fall/';
% sequence = 'traffic/';

directory_sequence = strcat('../Database/Week02/', sequence);

directory_write = strcat('../Results/week2/', sequence);
directory_write_grid = '../Results/week2/';
alpha = 0.1510;
rho = 0;    
percentage = 0.5;

param  = compute_parameters_w2(directory_sequence, directory_write, alpha, rho, percentage);


%%
%Computation_step
% imagesSeg = recursive_gaussian( param );

%Evaluation step
% [ ~, metrics2 ] = evaluate_model_adaptive( imagesSeg, param );



%%
%Grid search
min_alpha = 0.001;
step_alpha = 0.5;
max_alpha = 10;
alphas = min_alpha:step_alpha:max_alpha;

min_rho = 0;
step_rho = 0.1;   
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
name_file = strcat(directory_write_grid, 'Grid_search/', seq{1},'_grid_alpha_rho_new.mat' );
save(name_file, 'metrics_search', 'alphas', 'rhos')
%%
seq = strsplit(sequence, '/');
name_file = strcat(directory_write_grid, 'Grid_search/', seq{1},'_grid_alpha_rho.mat' );
load(name_file)
precision = shiftdim(metrics_search(:, :, 1));
recall = shiftdim(metrics_search(:, :, 2));
fmeasure = shiftdim(metrics_search(:, :, 3));
[Rho, Alpha] = meshgrid(rhos, alphas);
%Plot surfaces
% figure('units','normalized','outerposition',[0 0 1 1]), surf(Alpha, Rho, precision)

%  figure, surf(Alpha, Rho, recall)

max_fm_idx = find(fmeasure == (max(max(fmeasure))));
[i_max, j_max] = ind2sub(size(fmeasure), max_fm_idx);
% max_fm = fmeasure(i_max, j_max);
figure('units','normalized','outerposition',[0 0 1 1]),
surf( Rho, Alpha, fmeasure)
hold on
s = 150;
scatter3( rhos(j_max),alphas(i_max),fmeasure(i_max, j_max),s, 'filled')
text(rhos(j_max),alphas(i_max),fmeasure(i_max, j_max) + 0.05, ...
    strcat('Maximum value of F-measure:   ', num2str(fmeasure(i_max, j_max))),...
    'FontWeight', 'bold')

xlabel('Rho','FontWeight', 'bold')
ylabel('Alpha','FontWeight', 'bold')
zlabel('F-measure','FontWeight', 'bold')
title('Exhaustive search of F-measure ','FontWeight', 'bold')

colorbar
%%
max_fm_idx = find(fmeasure == (max(max(fmeasure))));


[i_max, j_max] = ind2sub(size(fmeasure), max_fm_idx);


max_fm = fmeasure(i_max, j_max);
[max_fm, alphas(i_max), rhos(j_max)]
% pixelPrecision, pixelRecall, pixelFMeasure]
% plot( shiftdim(metrics_search(1, 1, :)),shiftdim(metrics_search(1, 2, :)), 'r')
% %, alphas, shiftdim(metrics_search(1, 2,:)), 'g', alphas, shiftdim(metrics_search(1, 3,:)), 'b');
% title 'Precision Recall'
% xlabel('Alpha')
% ylabel('Value')
% legend('Precision','Recall','Fmeasure')


%%
% plot(alpha,metrics2(1,:),'r',alpha,metrics2(2,:),'g',alpha,metrics2(3,:),'b');
% title 'Precision Recall Fmeasure'
% xlabel('Alpha')
% ylabel('Value')
% legend('Precision','Recall','Fmeasure')
% figure,
% plot(metrics2(2,:),metrics2(1,:))
% title 'Precision Recall curve'
% xlabel('Recall')
% ylabel('Precision')
% figure,
% plot((metrics(2,:)./(metrics(2,:)+metrics(4,:))),metrics(1,:)./(metrics(1,:)+metrics(3,:)))
% title 'ROC curve'
% xlabel('FP ratio')
% ylabel('TP ratio')