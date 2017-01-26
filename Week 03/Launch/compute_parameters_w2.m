function params  = compute_parameters_w2(directory_sequence, directory_write, alpha, rho, percentage)
params.directory_imagesIn = strcat(directory_sequence, 'input/');
params.directory_imagesGT = strcat(directory_sequence, 'groundtruth/');

params.dirIn = dir([params.directory_imagesIn '/*.jpg']);
params.dirGT = dir([params.directory_imagesGT '/*.png']);

params.rho = rho;
params.alpha = alpha;
params.percentage = percentage;

params.directory_write = strcat(directory_write, 'Foreground_gray_alpha_', num2str(alpha), '_rho_', num2str(rho));

if ~exist(params.directory_write, 'dir')
  mkdir(params.directory_write);
end
im = imread(strcat(params.directory_imagesIn, params.dirIn(1).name));
[params.ni, params.nj, ~] = size(im);

end

