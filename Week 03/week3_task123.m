clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed
 sequence = 'highway/';
%sequence = 'fall/';
%sequence = 'traffic/';
task = 2;
cnn = 4;
percentage = 0.5;
thre_texture = 0;
% param  = compute_parameters_w3(sequence, directory_write, alpha, rho, percentage, thre_texture);


%%
% %Computation_step
% imagesSeg = recursive_gaussian( param );
% %Morphological step
% imagesSegMorph = morphological(imagesSeg,process_type);
% %Evaluation step
% [ ~, metrics2 ] = evaluate_model_adaptive( imagesSegMorph, param );

switch task
    case 1 
        process_type = 1;
        intervalpha = 0:0.05:0.3;
        switch sequence
            case 'highway/'
                alpha = 0.101;
                rho = 0.04;
        
            case 'fall/'
                alpha = 0.101;
                rho = 0.18;
                
            case 'traffic/'
                alpha = 0.151;
                rho = 0.09;
             
        end
        directory_sequence = strcat('../Database/Week02/', sequence);
        directory_write = strcat('../Results/week3/', sequence);
        contador = 0; 
        for alpha = intervalpha
                contador = contador + 1;
                param  = compute_parameters_w3(sequence, directory_write, alpha, rho, percentage, thre_texture);
                %Computation_step
                imagesSeg = recursive_gaussian( param );
                %Morphological step
                imagesSegMorph = morphological(imagesSeg,process_type);
                %Evaluation step
                [ metrics(:,contador), metrics2(:,contador) ] = evaluate_model_adaptive( imagesSegMorph, param );
         end
         auc = graphs(intervalpha,metrics,metrics2);
        
    case 2
        process_type = 2;
        intervalpha = 0:0.05:0.3;
        Results = [];
        switch sequence
            case 'highway/'
                alpha = 0.101;
                rho = 0.04;
                Pinter=0:10:100;
            case 'fall/'
                alpha = 0.101;
                rho = 0.18;
                Pinter=0:100:1000;
            case 'traffic/'
                alpha = 0.151;
                rho = 0.09;
                Pinter=0:5:30;
        end
        
        directory_sequence = strcat('../Database/Week02/', sequence);
        directory_write = strcat('../Results/week3/', sequence);
       
        for P = Pinter
            contador = 0; 

            for alpha = intervalpha
                    contador = contador + 1;
                    param  = compute_parameters_w3(sequence, directory_write, alpha, rho, percentage, thre_texture);
                    %Computation_step
                    imagesSeg = recursive_gaussian( param );
                    %Morphological step
                    imagesSegMorph = morphological(imagesSeg,process_type, P);
                    %Evaluation step
                    [ metrics(:,contador), metrics2(:,contador) ] = evaluate_model_adaptive( imagesSegMorph, param );
             end
             auc = areaundercurve(metrics2(2,:),metrics2(1,:));
             Results = [P auc;Results];
         end
         
    case 3
        switch sequence
            case 'highway/'
                process_type = 3;
                alpha = 0.101;
                rho = 0.04;
                P= 60;
            case 'fall/'
                process_type = 4;
                alpha = 0.101;
                rho = 0.18;
                P=700;
            case 'traffic/'
                process_type = 5;
                alpha = 0.151;
                rho = 0.09;
                P=30;
        end
        directory_sequence = strcat('../Database/Week02/', sequence);
        directory_write = strcat('../Results/week3/', sequence);

        param  = compute_parameters_w3(sequence, directory_write, alpha, rho, percentage, thre_texture);
        %Computation_step
        imagesSeg = recursive_gaussian( param );
        %Morphological step
        imagesSegMorph = morphological(imagesSeg,process_type,P,cnn);
        %Evaluation step
        [ ~, metrics2 ] = evaluate_model_adaptive( imagesSegMorph, param );
end

