function [ output_args ] = Shadow_removal( param )








train = 1:floor(param.percentage*length(param.dirIn));  
test = floor(param.percentage*length(param.dirIn)) + 1:length(param.dirIn);

imagesSeg_final = zeros(param.ni, param.nj, length(test));

full_images_train = zeros(param.ni, param.nj, 3, length(train));
full_images_test = zeros(param.ni, param.nj, 3, length(test));

final_mu_model = zeros(param.ni, param.nj, 3);
final_sigma_model = zeros(param.ni, param.nj, 3);

%Get images of each set
for i = train
    full_images_train(:, :, :, i) = im2double(imread(strcat(param.directory_imagesIn, param.dirIn(i).name)));
end

for i = 1:length(test)
    full_images_test(:, :, :, i) = im2double(imread(strcat(param.directory_imagesIn, param.dirIn(test(i)).name)));
end

for channel = 1:3
    images_train = full_images_train(:, :, channel, :);    
    images_test = full_images_test(:, :, channel, :);  
    imagesSeg = zeros(param.ni, param.nj, length(test));

    %For the first 50% of the images from the dataset, the background model is
    %trained.
    mu = mean(images_train, 3);
    sigma = std(images_train, 1, 3);
    
    
    %For the second 50% of the images from the dataset, the foreground is
    %segmented
    for i = 1:length(test)
        im = shiftdim(images_test(:, :, i));
        % Determine if a pixel is background or foreground
        segmentation = abs(im - mu) >= param.alpha*(2 + sigma);
        imagesSeg(:, :, i) = segmentation;
        % Save results
        imwrite( segmentation, strcat(param.directory_write,'/', param.dirIn(test(i)).name));
        
        
        %Update background model with pixels labeled as background
        mu = (1 - segmentation).*(param.rho*im + (1 - param.rho)*mu) + segmentation.*mu;
        sigma = sqrt((1 - segmentation).*(param.rho.*(im - mu).^2 + (1 - param.rho).*sigma.^2) + segmentation.*sigma.^2);
    end
    
end


end

