function [pixelTP,pixelFP,pixelFN,pixelTN,pixelPrecision, pixelRecall,pixelFMeasure] = PerformanceEvaluationPixel(TP_images, FP_images, FN_images, TN_images)
    % PerformanceEvaluationPixel
    % Function to compute different performance indicators (Precision, accuracy, 
    % specificity, sensitivity) at the pixel level
    %
    % [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN)
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'pixelTP'           Number of True  Positive pixels
    %    'pixelFP'           Number of False Positive pixels
    %    'pixelFN'           Number of False Negative pixels
    %    'pixelTN'           Number of True  Negative pixels
    %
    % The function returns the precision, accuracy, specificity and sensitivity
    pixelTP= sum(TP_images);
    pixelFP= sum(FP_images);
    pixelFN= sum(FN_images);
    pixelTN= sum(TN_images);
    
    pixelPrecision = pixelTP / (pixelTP+pixelFP);
    pixelRecall = pixelTP / (pixelTP+pixelFN);
    pixelFMeasure = (2*pixelTP)/(2*pixelTP + pixelFN + pixelFP);
    
end
%pixelPrecision(isnan(pixelPrecision)) = 0;
%pixelFMeasure(isnan(pixelFMeasure)) = 0;