function [ foreground_detection, shadows, M ] = Shadow_removal( param )

% Compute the foreground estimation using adaptive gaussian
[ imagesSeg_final, final_mu_model, ~ ] = recursive_gaussian_color( param );

test = floor(param.percentage*length(param.dirIn)) + 1:length(param.dirIn);

shadows_color = color_shadow_detection(param, imagesSeg_final, final_mu_model );

shadows_detected = shadows_color;
M = zeros(param.ni, param.nj, length(test));
marker = zeros(param.ni, param.nj, length(test));
foreground_detection = zeros(param.ni, param.nj, length(test));
shadows = zeros(param.ni, param.nj, length(test));

nhood_se = [0 1 0; 1 0 1; 0 1 0];
N = strel('arbitrary', nhood_se);
SE = strel('square', 6);
% M_s = imagesSeg_final
for i = 1:length(test)
    M(:, :, i) = and(imagesSeg_final(:, :, i), not(shadows_detected(:, :, i)));
    marker(:, :, i) = and(M(:, :, i), imdilate(M(:, :, i), N));
    foreground_detection(:, :, i) = and(imagesSeg_final(:, :, i), imdilate(marker(:, :, i), SE));
    shadows(:, :, i) = and(not(foreground_detection(:, :, i)), imagesSeg_final(:, :, i));
    
%     I = imfill(foreground_detection(:,:,i),param.cnn,'holes');
    I = imfill(M(:,:,i),param.cnn,'holes');
    Iarea = bwareaopen(I, param.P, param.cnn);
    foreground_detection(:,:,i)= Iarea;
    
end
end