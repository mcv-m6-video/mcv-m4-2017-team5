function [ imagesSeg ] = recursive_gaussian(sequence_dir,percentage,alpha,rho,directory_write)
    if ~exist(directory_write, 'dir')
        mkdir(directory_write);
    end

    files=dir(strcat(sequence_dir,'/*.jpg'));

    train = 1:floor(percentage*length(files));
    test = floor(percentage*length(files)) + 1:length(files);

    [ni,nj,~]=size(imread(strcat(sequence_dir,filesep,files(1).name)));

    images_train = zeros(ni, nj, length(train));
    images_test = zeros(ni, nj, length(test));
    imagesSeg = zeros(ni, nj, length(test));


    for i = train
        image=im2double(imread(strcat(sequence_dir,filesep,files(i).name)));
        if size(image,3)==3
            images_train(:, :, i) = rgb2gray(image);
        else
            images_train(:, :, i) = image;
        end
    end

    for i = 1:length(test)
        image=im2double(imread(strcat(sequence_dir,filesep,files(test(i)).name)));
        if size(image,3)==3
            images_test(:, :, i) = rgb2gray(image);
        else
            images_test(:, :, i) = image;
        end
    end    
    %For the first 50% of the images from the dataset, the background model is
    %trained.
    mu = mean(images_train, 3);
    sigma = std(images_train, 0, 3);


    %For the second 50% of the images from the dataset, the foreground is
    %segmented
    for i = 1:length(test)
        im = shiftdim(images_test(:, :, i));
        % Determine if a pixel is background or foreground
        segmentation = abs(im - mu) >= alpha*(2 + sigma);
        imagesSeg(:, :, i) = segmentation;
        % Save results
        imwrite( segmentation, strcat(directory_write,'/', files(test(i)).name));


        %Update background model with pixels labeled as background
        mu = (1 - segmentation).*(rho*im + (1 - rho)*mu) + segmentation.*mu;
        sigma = sqrt((1 - segmentation).*(rho*(im - mu).^2 + (1 - rho)*sigma.^2) + segmentation.*sigma.^2);
    end
end