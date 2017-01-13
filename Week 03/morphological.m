function [ images_processed ] = morphological( images, process_type, plot )
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
                %Traffic process_type = 2
                %Highway process_type = 3
                %Fall process_type = 4
                %FillHoles is done by selecting process_type = 1.
        
%   Default parameters:
        %If the number of input parameters given is just one (the images),
        %the function assumes the process type is the first one and that
        %the plot is wanted. Besides, if the process type is selected but
        %not the plot decission, this is assumed wanted as well.
        
    if nargin < 2
        process_type = 1;
        plot = true;
    end
    
    if nargin == 2
        plot = true;
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
               I = imfill(images(:,:,i),'holes');
               images_pr(:,:,i)= I;
            end   
            
        case 2
            for i = 1:dim3
                I = imfill(images(:,:,i),'holes');
                Icl = imopen(I,se4);
                Iocl = imclose(Icl,se2);
                images_pr(:,:,i)=Iocl;
            end
        case 3
            for i = 1:dim3
               I = imfill(images(:,:,i),'holes');
               Icl = imclose(I,se3);
               Io = imopen(Icl,se1);
               If = imfill(Io,'holes');
               images_pr(:,:,i) = If;
            end
        case 4
            for i = 1:dim3
               I = imfill(images(:,:,i),'holes');
               Io = imopen(I,se6);
               Iof = imfill(Io,'holes');
               Icl = imclose(Iof,se5);
               Iclf = imfill(Icl,'holes');
               images_pr(:,:,i) = Iclf;
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

