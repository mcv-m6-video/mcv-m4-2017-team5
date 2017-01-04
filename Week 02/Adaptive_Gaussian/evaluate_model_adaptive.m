function [ metrics, metrics2 ] = evaluate_model_adaptive( imagesSeg, param )

test = floor(param.percentage*length(param.dirIn)) + 1:length(param.dirIn);

TP_images = zeros(length(test), 1);
FP_images = zeros(length(test), 1);
FN_images = zeros(length(test), 1);
TN_images = zeros(length(test), 1);


for i = 1:length(test)
    
    imageGT = imread(strcat(param.directory_imagesGT, param.dirGT(test(i)).name));
    image = imagesSeg(:, :, i);
    [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(image, imageGT);
    TP_images(i) = pixelTP;
    FP_images(i) = pixelFP;
    FN_images(i) = pixelFN;
    TN_images(i) = pixelTN;
    
end
[pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images);
metrics = [pixelTP, pixelFP, pixelFN, pixelTN];
metrics2 = [pixelPrecision, pixelRecall, pixelFMeasure];
end

