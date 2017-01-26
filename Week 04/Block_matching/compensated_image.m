function [ comp_im ] = compensated_image( params, flow_estimation )
% Read images
Image_01 = double(imread(strcat(params.directory_images, params.image01)));
% Image_02 = double(imread(strcat(params.directory_images, params.image02)));

[ni, nj, ~] = size(Image_01);
comp_im = zeros(ni, nj);
for i = 1:ni
    for j = 1:nj
        comp_im(i, j) = Image_01(i - flow_estimation(i, j, 1), j - flow_estimation(i, j, 2));
    end
end    
end

