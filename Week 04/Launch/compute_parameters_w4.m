function params  = compute_parameters_w4(directory_images, path_ground_truth, image, N, P, fwd_or_bwd)


params.directory_images = strcat(directory_images, image);
params.directory_GT = strcat(path_ground_truth, image, '_10.png');


params.N = N;
params.P = P;
if strcmp(fwd_or_bwd, 'forward')
    params.image01 = '_10.png';
    params.image02 = '_11.png';
else
    params.image01 = '_11.png';
    params.image02 = '_10.png';
end 
params.tau = 3;
end

