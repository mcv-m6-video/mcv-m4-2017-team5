function [ foreground_detection ] = Shadow_removal( param )

% Compute the foreground estimation using adaptive gaussian
[ imagesSeg_final, final_mu_model, ~ ] = recursive_gaussian_color( param );

test = floor(param.percentage*length(param.dirIn)) + 1:length(param.dirIn);

shadows_color = color_shadow_detection(param, imagesSeg_final, final_mu_model );
shadows_texture = texture_shadow_detection(param, imagesSeg_final, final_mu_model );

shadows_detected = and(shadows_color, shadows_texture);
M = zeros(param.ni, param.nj, length(test));
marker = zeros(param.ni, param.nj, length(test));
foreground_detection = zeros(param.ni, param.nj, length(test));

nhood_se = [0 1 0; 1 0 1; 0 1 0];
N = strel('arbitrary', nhood_se);
SE = strel('square', 9);
% M_s = imagesSeg_final
for i = 1:length(test)
    M(:, :, i) = and(imagesSeg_final(:, :, i), not(shadows_detected(:, :, i)));
    marker(:, :, i) = and(M(:, :, i), imdilate(M(:, :, i), N));
    foreground_detection(:, :, i) = and(imagesSeg_final(:, :, i), imdilate(marker(:, :, i), SE));
end


end

