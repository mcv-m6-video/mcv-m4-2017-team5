function [ imagesSeg_final, final_mu_model, final_sigma_model ] = recursive_gaussian_color( param )


train = 1:floor(param.percentage*length(param.dirIn));    
test = floor(param.percentage*length(param.dirIn)) + 1:length(param.dirIn);

imagesSeg_final = ones(param.ni, param.nj, length(test));

full_images_train = zeros(param.ni, param.nj, 3, length(train));
full_images_test = zeros(param.ni, param.nj, 3, length(test));

final_mu_model = zeros(param.ni, param.nj, 3);
final_sigma_model = zeros(param.ni, param.nj, 3);

%Get images of each set
for i = train
    full_images_train(:, :, :, i) = double(imread(strcat(param.directory_imagesIn, param.dirIn(i).name)));
end

for i = 1:length(test)
    full_images_test(:, :, :, i) = double(imread(strcat(param.directory_imagesIn, param.dirIn(test(i)).name)));
end

for channel = 1:3
    images_train = shiftdim(full_images_train(:, :, channel, :));    
    images_test = shiftdim(full_images_test(:, :, channel, :));  
    

    %For the first 50% of the images from the dataset, the background model is
    %trained.
    mu = mean(images_train, 4);
    sigma = std(images_train, 1, 4);
    
    
    %For the second 50% of the images from the dataset, the foreground is
    %segmented
    for i = 1:length(test)
        im = shiftdim(images_test(:, :, :, i));
        % Determine if a pixel is background or foreground
        segmentation = abs(im - mu) >= param.alpha*(2 + sigma);
        imagesSeg_final(:, :, i) = segmentation.*imagesSeg_final(:, :, i);
        % Save results
%         imwrite( segmentation, strcat(param.directory_write,'/', param.dirIn(test(i)).name));
               
        %Update background model with pixels labeled as background
        mu = (1 - segmentation).*(param.rho*im + (1 - param.rho)*mu) + segmentation.*mu;
        sigma = sqrt((1 - segmentation).*(param.rho.*(im - mu).^2 + (1 - param.rho).*sigma.^2) + segmentation.*sigma.^2);
    end
    final_mu_model(:, :, channel) = mu;
    final_sigma_model(:, :, channel) = sigma;
end
end