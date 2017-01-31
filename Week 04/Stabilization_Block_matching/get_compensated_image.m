function comp_im = get_compensated_image(flow_estimation,frame2)
%Computes the average of the optical flow on the image, and does the
%compensation

    average_flow=[-int32(mean(mean(flow_estimation(:,:,1)))), -int32(mean(mean(flow_estimation(:,:,2))))];  
    
    comp_im = imtranslate(frame2,[average_flow(1),average_flow(2)]);
    
end

