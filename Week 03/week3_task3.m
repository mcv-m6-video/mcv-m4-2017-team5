clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed
% sequence = 'highway/';
% sequence = 'fall/';
 sequence = 'traffic/';

switch sequence
    case 'highway/'
        process_type = 3;
        alpha = 0.101;
        rho = 0.04;
    case 'fall/'
        process_type = 4;
        alpha = 0.101;
        rho = 0.18;
    case 'traffic/'
        process_type = 2;
        alpha = 0.151;
        rho = 0.09;        
end
directory_sequence = strcat('../Database/Week02/', sequence);

directory_write = strcat('../Results/week3/', sequence);
directory_write_grid = '../Results/week3/';
% alpha = 0.101;
% rho = 0.04;
percentage = 0.5;

param  = compute_parameters_w3(sequence, directory_write, alpha, rho, percentage);


%%
%Computation_step
imagesSeg = recursive_gaussian( param );
%Morphological step
imagesSegMorph = morphological(imagesSeg,process_type);
%Evaluation step
[ ~, metrics2 ] = evaluate_model_adaptive( imagesSegMorph, param );



% %%
% %Grid search
% min_alpha = 0.001;
% step_alpha = 0.5;
% max_alpha = 10;
% alphas = min_alpha:step_alpha:max_alpha;
% 
% min_rho = 0;
% step_rho = 0.1;
% max_rho = 1;
% rhos = min_rho:step_rho:max_rho;
% 
% 
% dim1 = length(alphas);
% dim2 = length(rhos);
% 
% 
% param  = compute_parameters_w2(directory_sequence, directory_write, 0, 0, percentage);
% 
% % 3 matrices with metrics for each pair of values of alpha and rho
% %1: precision
% %2:recall
% %3:f-measure
% metrics_search = zeros(dim1, dim2, 3);
% for j = 1:dim2
%     for i = 1:dim1
%         
%         sub2ind([dim1 dim2], i, j)
%         param.alpha = alphas(i);
%         param.rho = rhos(j);
%         
%         %Computation_step
%         imagesSeg = recursive_gaussian( param );
%         
%         %Evaluation step
%         [ ~, metrics2 ] = evaluate_model_adaptive( imagesSeg, param );
%         metrics_search(i, j, 1) = metrics2(1);
%         metrics_search(i, j, 2) = metrics2(2);
%         metrics_search(i, j, 3) = metrics2(3);
%     end
% end
% seq = strsplit(sequence, '/');
% if ~exist(strcat(directory_write_grid, 'Grid_search/'), 'dir')
%     mkdir(strcat(directory_write_grid, 'Grid_search/'));
% end
% name_file = strcat(directory_write_grid, 'Grid_search/', seq{1},'_grid_alpha_rho_new.mat' );
% save(name_file, 'metrics_search', 'alphas', 'rhos')
% %%
% %Plot surface
% seq = strsplit(sequence, '/');
% name_file = strcat(directory_write_grid, 'Grid_search/', seq{1},'_grid_alpha_rho.mat' );
% load(name_file)
% 
% fmeasure = shiftdim(metrics_search(:, :, 3));
% [Rho, Alpha] = meshgrid(rhos, alphas);
% %Plot surfaces
% % figure('units','normalized','outerposition',[0 0 1 1]), surf(Alpha, Rho, precision)
% 
% %  figure, surf(Alpha, Rho, recall)
% 
% max_fm_idx = find(fmeasure == (max(max(fmeasure))));
% [i_max, j_max] = ind2sub(size(fmeasure), max_fm_idx);
% % max_fm = fmeasure(i_max, j_max);
% figure('units','normalized','outerposition',[0 0 1 1]),
% % figure,
% surf( Rho, Alpha, fmeasure)
% hold on
% s = 150;
% scatter3( rhos(j_max),alphas(i_max),fmeasure(i_max, j_max),s, 'filled')
% text(rhos(j_max),alphas(i_max),fmeasure(i_max, j_max) + 0.05, ...
%     strcat('Maximum value of F-measure:   ', num2str(fmeasure(i_max, j_max))),...
%     'FontWeight', 'bold')
% 
% xlabel('Rho','FontWeight', 'bold')
% ylabel('Alpha','FontWeight', 'bold')
% zlabel('F-measure','FontWeight', 'bold')
% title(strcat('Exhaustive search of F-measure in      ' ,{ ' '}, seq{1}, ' sequence'),'FontWeight', 'bold')
% axis square
% 
% %%
% sequences = { 'highway/', 'fall/', 'traffic/'};
% for sequ = 1:3
%     sequence = sequences{sequ};
%     directory_sequence = strcat('../Database/Week02/', sequence);
%     
%     directory_write = strcat('../Results/week2/', sequence);
%     param  = compute_parameters_w2(directory_sequence, directory_write, 0, 0, percentage);
%     clear metrics_search alphas rhos
%     seq = strsplit(sequence, '/');
%     name_file = strcat(directory_write_grid, 'Grid_search/', seq{1},'_grid_alpha_rho.mat' );
%     load(name_file)
%     fmeasure = shiftdim(metrics_search(:, :, 3));
%     max_fm_idx = find(fmeasure == (max(max(fmeasure))));
%     [~, j_max] = ind2sub(size(fmeasure), max_fm_idx);
%     rho = rhos(j_max);
%     param.rho = rho;
%     lineserach_trues = zeros(length(alphas), 4);
%     for i = 1:length(alphas)
%         
%         param.alpha = alphas(i);
%         
%         
%         %Computation_step
%         imagesSeg = recursive_gaussian( param );
%         
%         %Evaluation step
%         [ metrics, ~ ] = evaluate_model_adaptive( imagesSeg, param );
%         lineserach_trues(i, :) = metrics;
%         
%         
%     end
%     
%     name_file2 = strcat(directory_write_grid, 'Grid_search/', seq{1},'_line_alpha_(rho_fixed).mat' );
%     save(name_file2, 'lineserach_trues', 'alphas', 'rhos')
% end
% %%
% 
% 
% sequences = { 'highway/', 'fall/', 'traffic/'};
% color = {'r', 'g', 'b'};
% figure(1)
% for sequ = 1:3
%     sequence = sequences{sequ};
%     directory_sequence = strcat('../Database/Week02/', sequence);
%     
%     directory_write = strcat('../Results/week2/', sequence);
%     param  = compute_parameters_w2(directory_sequence, directory_write, 0, 0, percentage);
%     clear metrics_search alphas rhos lineserach_trues
%     seq = strsplit(sequence, '/');
%     name_file = strcat(directory_write_grid, 'Grid_search/', seq{1},'_grid_alpha_rho.mat' );
%     load(name_file)
%     name_file2 = strcat(directory_write_grid, 'Grid_search/', seq{1},'_line_alpha_(rho_fixed).mat' );
%     load(name_file2)
%     fmeasure = shiftdim(metrics_search(:, :, 3));
%     max_fm_idx = find(fmeasure == (max(max(fmeasure))));
%     [~, j_max] = ind2sub(size(fmeasure), max_fm_idx);
%     rho = rhos(j_max);
%     param.rho = rho;
%     metrics = lineserach_trues;
%     metrics2 = shiftdim(metrics_search(:, j_max, :));
%     %     plot(alphas',metrics2(:,1),'r',alphas',metrics2(:,2),'g',alphas',metrics2(:,3),'b');
%     %     title 'Precision Recall Fmeasure'
%     %     xlabel('Alpha')
%     %     ylabel('Value')
%     %     legend('Precision','Recall','Fmeasure')
%     
%     plot(metrics2(:,2),metrics2(:,1), color{sequ})
%     title 'Precision Recall curve'
%     xlabel('Recall')
%     ylabel('Precision')
%     auc = areaundercurve(metrics2(2,:),metrics2(1,:));
%     hold on
%     
%     %     plot((metrics(2,:)./(metrics(2,:)+metrics(4,:))),metrics(1,:)./(metrics(1,:)+metrics(3,:)))
%     %     title 'ROC curve'
%     %     xlabel('FP ratio')
%     %     ylabel('TP ratio')
%     %     hold on
% end
% legend('highway', 'fall', 'traffic')
% legend(strcat('highway auc=',num2str(0.3162)),strcat('fall auc= ', num2str(0.4843)), strcat('traffic auc=',num2str(0.3855)))
% %%
% 
% sequence = 'traffic/';
% 
% directory_sequence = strcat('../Database/Week02/', sequence);
% 
% directory_write = strcat('../Results/week2/', sequence);
% directory_write_grid = '../Results/week2/';
% directory_write_gif = '../Results/week2/Video/';
% 
% seq = strsplit(sequence, '/');
% name_file = strcat(directory_write_grid, 'Grid_search/', seq{1},'_grid_alpha_rho.mat' );
% load(name_file)
% fmeasure = shiftdim(metrics_search(:, :, 3));
% max_fm_idx = find(fmeasure == (max(max(fmeasure))));
% [i_max, j_max] = ind2sub(size(fmeasure), max_fm_idx);
% alpha = alphas(i_max);
% rho = rhos(j_max);
% param  = compute_parameters_w2(directory_sequence, directory_write, alpha, rho, percentage);
% imagesSeg_adaptive = recursive_gaussian( param );
% 
% alpha = 0.176;
% rho = 0;
% param  = compute_parameters_w2(directory_sequence, directory_write, alpha, rho, percentage);
% imagesSeg_nonadaptive = recursive_gaussian( param );
% 
% 
% filename = strcat(directory_write_gif, seq{1}, '_compare.gif');
% 
% if ~exist(directory_write_gif, 'dir')
%     mkdir(directory_write_gif);
% end
% figure('Color', 'white'),
% for i = 1:51
%     
%     subplot(121);
%     imshow(imagesSeg_nonadaptive(:, :, i));
%     title('Non-adaptive foreground detection')
%     subplot(122),
%     imshow(imagesSeg_adaptive(:, :, i));
%     title('Adaptive foreground detection')
%     
%     
%     frame = getframe(gcf);
%     im = frame2im(frame);
%     [imind, cm] = rgb2ind(im, 256);
%     
%     % On the first loop, create the file. In subsequent loops, append.
%     if i == 1
%         imwrite(imind,cm,filename,'gif','DelayTime',0,'Loopcount',inf);
%     else
%         imwrite(imind,cm,filename,'gif','DelayTime',0,'WriteMode','append');
%     end
%     
% end