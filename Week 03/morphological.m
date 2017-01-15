function [ images_processed ] = morphological( images, process_type, P , cnn ,plot )
%morphological. This function applies morphological operators to the
%foreground segmentation so such segmentation is improved. In order to do
%that, noise is intended to be removed and holes on the detected objects
%are filled.

%   In parameters:
        %images: matrix with the frames of the video segmented. The third
        %dimension are the images and the first and the second one are the
        %dimensions of each frame.
        
%   Out parameters:
        %images_processed: images after applying morphological operators.
        %Same syntaxis than the images parameter.
        
%   Further considerations:        
        %Depending on the secuence one different processing must be
        %performed. The process_type for each sequence would be:
                %Task 1 process_type = 1
                %Task 2 process_type = 2
                %Highway process_type = 3
                %Fall process_type = 4
                %Traffic process_type = 5

        
%   Default parameters:
        %If the number of input parameters given is just one (the images),
        %the function assumes the process type is the first one and that
        %the plot is wanted. Besides, if the process type is selected but
        %not the plot decission, this is assumed wanted as well.
        
    if nargin < 2
        process_type = 1;
        cnn = 4;
        P = 30;
        plot = false;
    elseif nargin < 3
        cnn = 4;
        P = 30;
        plot = false;
    elseif nargin < 4
        cnn = 4;
        plot = false;
    elseif nargin == 4 
        plot = false;
    end
    close all
    [dim1,dim2,dim3] = size(images);
    images_pr = zeros(dim1,dim2,dim3);

    %First, structural elements are created:
    se1 = strel('diamond',2);
    se2 = strel('diamond',20);
    se3 = strel('diamond',6);
    se4 = strel('line',10,45);
    se5 = strel('diamond',7);
    se6 = strel('diamond',3);
    
    %then, morphological operators are applied:
    switch process_type
        case 1
            for i = 1:dim3
               I = imfill(images(:,:,i),cnn,'holes');
               images_pr(:,:,i)= I;
            end   
            
        case 2
            for i = 1:dim3
               I = imfill(images(:,:,i),cnn,'holes');
               Iarea = bwareaopen(I,P,cnn);
               images_pr(:,:,i)= Iarea;
            end
        case 3
            for i = 1:dim3
               I = imfill(images(:,:,i),cnn,'holes');
               Iarea = bwareaopen(I,P,cnn);
               Icl = imclose(Iarea,se3);
               Io = imopen(Icl,se1);
               If = imfill(Io,'holes');
               images_pr(:,:,i) = If;
            end
        case 4
            for i = 1:dim3
               I = imfill(images(:,:,i),cnn,'holes');
               Iarea = bwareaopen(I,P,cnn);
               Io = imopen(Iarea,se6);
               Iof = imfill(Io,'holes');
               Icl = imclose(Iof,se5);
               Iclf = imfill(Icl,'holes');
               images_pr(:,:,i) = Iclf;
            end
        case 5 
            for i = 1:dim3
                I = imfill(images(:,:,i),cnn,'holes');
                Iarea = bwareaopen(I,P,cnn);
                Icl = imopen(Iarea,se4);
                Iocl = imclose(Icl,se2);
                images_pr(:,:,i)=Iocl;
            end
    end
            
    
    % For plotting the result
    if plot
    for k = 1:dim3
        imshow(images_pr(:,:,k));
    end
    end
    
    images_processed = images_pr;
end

