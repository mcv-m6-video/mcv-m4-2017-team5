function performForegroundDetection(directory_sequence,directory_write,gt_dir)
    intervalpha = 0:0.02:0.28;%Alpha values
    percentage = 0.5;

    %Plot Precision-Recall
    figure();
    xlabel('Recall')
    ylabel('Precision')

    process_type = 5;
    rho = 0.09;
    P=30;
    plotcolor='b';

    contador = 0;
    for alpha = intervalpha
        contador = contador + 1;
        
        %Computation_step
        imagesSeg = recursive_gaussian(directory_sequence,percentage,alpha,rho,directory_write);
        %Morphological step
        imagesSegMorph = morphological(imagesSeg,process_type, P);
        %Evaluation step
        [metrics(:,contador), metrics2(:,contador)] = evaluate_model_adaptive(imagesSegMorph, percentage, gt_dir);
    end

    %Plot Precision-Recall
    plot(metrics2(2,:),metrics2(1,:),plotcolor)
    hold on;
    %AUC
    auc = areaundercurve(metrics2(2,:),metrics2(1,:));

    disp(strcat('AUC'));
    disp(auc);
end