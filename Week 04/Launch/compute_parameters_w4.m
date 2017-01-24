function params  = compute_parameters_w3(sequence, directory_write, alpha, rho, percentage, thre_texture)

directory_sequence = strcat('../Database/Week02/', sequence);
params.directory_imagesIn = strcat(directory_sequence, 'input/');
params.directory_imagesGT = strcat(directory_sequence, 'groundtruth/');

params.dirIn = dir([params.directory_imagesIn '/*.jpg']);
params.dirGT = dir([params.directory_imagesGT '/*.png']);

params.rho = rho;
params.alpha = alpha;
params.percentage = percentage;
params.thre_texture = thre_texture;

params.directory_write = strcat(directory_write, 'Foreground_gray_alpha_', num2str(alpha), '_rho_', num2str(rho));

if ~exist(params.directory_write, 'dir')
  mkdir(params.directory_write);
end
im = imread(strcat(params.directory_imagesIn, params.dirIn(1).name));
[params.ni, params.nj, ~] = size(im);

end

