clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed
sequence = 'highway/';
% sequence = 'fall/';
% sequence = 'traffic/';


directory_write = strcat('../Results/week3/', sequence);
directory_write_grid = '../Results/week3/';
%Highway FM = 0.6210 alpha = 2.5 rho = 0.2 thre_texture = 15
%Fall FM = 0.6445 alpha = 3.001 rho = 0.1
%Traffic FM = 0.6247 alpha = 3.001 rho = 0.1
alpha = 2.5;
rho = 0.2;
percentage = 0.5;
thre_texture = 15;

param  = compute_parameters_w3(sequence, directory_write, alpha, rho, percentage, thre_texture);
param.P = 700;
param.cnn = 4;
%%

[ imagesSeg_final, final_mu_model, final_sigma_model ] = recursive_gaussian_color( param );
shadows_texture = texture_shadow_detection(param, imagesSeg_final, final_mu_model );
% figure
% for i = 1:size(imagesSeg_final, 3);
%    imshow(shadows_texture(:, :, i))
% end
%%
shadows_color = color_shadow_detection(param, imagesSeg_final, final_mu_model ); 
shadows_detected = and(shadows_color, shadows_texture);
% figure,
% for i = 1:size(imagesSeg_final, 3);
%    imshow(shadows_detected(:, :, i))
% end
figure,
% for j = 1:5
% for i = 1:size(imagesSeg_final, 3);
%    imshow(shadows_color(:, :, i))
% end
% end
%%
figure,
for i = 1:size(imagesSeg_final, 3);
   imshow(imagesSeg_final(:, :, i))
end


%%
[ foreground_detection, shadows, M ]  = Shadow_removal( param );
% for j = 1:5
%     for i = 1:size(foreground_detection, 3);
%         
%         imshow(foreground_detection(:, :, i))
%         
%         
%     end
% end
[ ~, metrics2 ] = evaluate_model_adaptive( foreground_detection, param );

%%
for i = 1:size(foreground_detection, 3);
    
%     imwrite(foreground_detection(:, :, i), strcat('../Results/seq_', num2str(i), '.png'))
    
    
end