function [ imagesSeg ] = recursive_gaussian_color( param )


train = 1:floor(param.percentage*length(param.dirIn));

test = floor(param.percentage*length(param.dirIn)) + 1:length(param.dirIn);


images_train = zeros(param.ni, param.nj, 3, length(train));
images_test = zeros(param.ni, param.nj, 3, length(test));
imagesSeg = zeros(param.ni, param.nj, length(test));


for i = train
    images_train(:, :, :, i) = (im2double(imread(strcat(param.directory_imagesIn, param.dirIn(i).name))));
end

for i = 1:length(test)
    images_test(:, :, :,i) = (im2double(imread(strcat(param.directory_imagesIn, param.dirIn(test(i)).name))));
end    
%For the first 50% of the images from the dataset, the background model is
%trained.
mu = mean(images_train);
sigma = std(images_train);


%For the second 50% of the images from the dataset, the foreground is
%segmented
for i = 1:length(test)
    im = shiftdim(images_test(:, :, :, i));
    % Determine if a pixel is background or foreground
    segmentation = ...
        abs(images_test(:,:,1,i)-mu(:,:,1)) >= alpha*(2+sigma(:,:,1)) &...
        abs(images_test(:,:,2,i)-mu(:,:,2)) >= alpha*(2+sigma(:,:,2)) &...
        abs(images_test(:,:,3,i)-mu(:,:,3)) >= alpha*(2+sigma(:,:,3));
    imagesSeg(:, :, i) = segmentation;
    % Save results
    imwrite( segmentation, strcat(param.directory_write,'/', param.dirIn(test(i)).name));
    
    
    %Update background model with pixels labeled as background
    mu = (1 - segmentation).*(param.rho*im + (1 - param.rho)*mu) + segmentation.*mu;
    sigma = sqrt((1 - segmentation).*(param.rho.*(im - mu).^2 + (1 - param.rho).*sigma.^2) + segmentation.*sigma.^2);
    
end
end

