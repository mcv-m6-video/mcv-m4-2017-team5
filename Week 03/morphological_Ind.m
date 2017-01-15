function [ images_processed ] = morphological_Ind( images, process_type)
%morphologicalInd. This function applies morphological operators to the
%foreground segmentation so such segmentation is improved. In order to do
%that, noise is intended to be removed and holes on the detected objects
%are filled. This function is used for each frame separately

%   In parameters:
        %images: matrix with the frames of the video segmented. 
        
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
        %the function assumes the process type is the first one.
        
    if nargin < 2
        process_type = 1;

    end

    close all
    [dim1,dim2] = size(images);
    images_pr = zeros(dim1,dim2);

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

               I = imfill(images,'holes');
               images_pr= I;
 
            
        case 2

                I = imfill(images,'holes');
                Icl = imopen(I,se4);
                Iocl = imclose(Icl,se2);
                images_pr=Iocl;

        case 3

               I = imfill(images,'holes');
               Icl = imclose(I,se3);
               Io = imopen(Icl,se1);
               If = imfill(Io,'holes');
               images_pr = If;
               
        case 4

               I = imfill(images,'holes');
               Io = imopen(I,se6);
               Iof = imfill(Io,'holes');
               Icl = imclose(Iof,se5);
               Iclf = imfill(Icl,'holes');
               images_pr = Iclf;
        
    end
            
    

    images_processed = images_pr;
end
