function performForegroundDetection(directory_sequence,directory_write,gt_dir, dir_unstabilized_seq)
    compare_unstab = true;
    if nargin < 4
        compare_unstab = false;
    end

    intervalpha = 0:0.02:0.28;%Alpha values
    percentage = 0.5;

    %Plot Precision-Recall
    figure();

    process_type = 5;
    rho = 0.09;
    P=30;
    
    contador = 0;
    for alpha = intervalpha
        contador = contador + 1;
        
        %Computation_step
        imagesSeg = recursive_gaussian(directory_sequence,percentage,alpha,rho,directory_write);
        %Morphological step
        imagesSegMorph = morphological(imagesSeg,process_type, P);
        %Evaluation step
        [~, metrics2(:,contador)] = evaluate_model_adaptive(imagesSegMorph, percentage, gt_dir);
        
        %For unstabilized sequence
        if compare_unstab
            unstab_imagesSeg = recursive_gaussian(dir_unstabilized_seq,percentage,alpha,rho,directory_write);
            un_imagesSegMorph = morphological(unstab_imagesSeg,process_type, P);
            [~, un_metrics2(:,contador)] = evaluate_model_adaptive(un_imagesSegMorph, percentage, gt_dir);
        end
    end

    %Plot Precision-Recall
    plot(metrics2(2,:),metrics2(1,:),'b')
    legend('Stabilized')
    hold on;
    
    %AUC
    auc = areaundercurve(metrics2(2,:),metrics2(1,:));
    
    disp(strcat('AUC stabilized'));
    disp(auc);
    
    %Unstabilized
    if compare_unstab
        plot(un_metrics2(2,:),un_metrics2(1,:),'r')
        legend('Stabilized','Unstabilized')
        un_auc = areaundercurve(un_metrics2(2,:),un_metrics2(1,:));
        
        disp(strcat('AUC unstabilized'));
        disp(un_auc);
    end
    
    xlabel('Recall')
    ylabel('Precision')
    
end