function [ shadows_color ] = color_shadow_detection(param, imagesSeg_final, final_mu_model )

test = floor(param.percentage*length(param.dirIn)) + 1:length(param.dirIn);

shadows_color = ones(param.ni, param.nj, length(test));
background_model = final_mu_model;

for i = 1:length(test)
    %Read image in color
    im = double(imread(strcat(param.directory_imagesIn, param.dirIn(test(i)).name)));
    
    %Take segmentation obtained from adaptive model
    segmentation = imagesSeg_final(:, :, i);
    
    %Determine foreground points
    foreground_points = im.* cat(3, segmentation, segmentation, segmentation);
    
    norm_back = sum(background_model.^2, 3);
    BD = sum(foreground_points.*background_model, 3)./norm_back;
    
    CD = sqrt(sum((foreground_points - background_model.*cat(3, BD, BD, BD)).^2, 3));
    
    shadows_color(:, :, i) = and(CD < 15, and (BD > 0.5, BD < 1));
end    
end
% for i = 1:length(test)
%     %Read image in color
%     im = im2double(imread(strcat(param.directory_imagesIn, param.dirIn(test(i)).name)));
%     %Take segmentation obtained from adaptive model
%     segmentation = imagesSeg_final(:, :, i);
%     %Determine foreground points
%     foreground_points = im.* cat(3, segmentation, segmentation, segmentation);
%     subplot(121)
%     imshow(foreground_points)
%     subplot(122)
%     imshow(im)
% end 
