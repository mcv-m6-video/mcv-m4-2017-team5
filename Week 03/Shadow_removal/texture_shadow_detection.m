function [ shadows_texture ] = texture_shadow_detection(param, imagesSeg_final, final_mu_model )

    
test = floor(param.percentage*length(param.dirIn)) + 1:length(param.dirIn);

shadows_texture = zeros(param.ni, param.nj, length(test));
background_model = final_mu_model;

for i = 1:length(test)
    
    im_gray = mean(double(imread(strcat(param.directory_imagesIn, param.dirIn(test(i)).name))), 3);
    model_gray = mean(background_model, 3);
    
    [Gx_im, Gy_im] = imgradientxy(im_gray);
    [Gx_model, Gy_model] = imgradientxy(model_gray);
    
    dist_im_model = sqrt((Gx_im - Gx_model).^2 + (Gy_im - Gy_model).^2);
    
    segmentation = imagesSeg_final(:, :, i);
    
    dist_foreground_points = dist_im_model.*segmentation;
    
    shadows_texture(:, :, i) = and(dist_foreground_points < param.thre_texture, dist_foreground_points > 0);
end    
end