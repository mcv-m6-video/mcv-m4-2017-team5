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
alpha = 1.510;
rho = 0;
percentage = 0.5;
thre_texture = 1.5;

param  = compute_parameters_w3(sequence, directory_write, alpha, rho, percentage, thre_texture);



[ imagesSeg_final, final_mu_model, final_sigma_model ] = recursive_gaussian_color( param );
shadows_color = color_shadow_detection(param, imagesSeg_final, final_mu_model ); 
for i = 1:size(imagesSeg_final, 3);
   imshow(shadows_color(:, :, i))
end
%%

shadows_texture = texture_shadow_detection(param, imagesSeg_final, final_mu_model );
for i = 1:size(imagesSeg_final, 3);
   imshow(shadows_texture(:, :, i))
end
%%
for i = 1:size(imagesSeg_final, 3);
   imshow(imagesSeg_final(:, :, i))
end
%%



%%
foreground_detection  = Shadow_removal( param );

for i = 1:size(foreground_detection, 3);
    imshow(foreground_detection(:, :, i))
end
