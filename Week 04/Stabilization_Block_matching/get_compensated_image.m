function comp_im = get_compensated_image(flow_estimation,frame2)
    [ni, nj, ~] = size(frame2);
    comp_im = zeros(ni, nj);
    for i = 1:ni
        for j = 1:nj
            new_i = i-flow_estimation(i,j,1);
            new_j = j-flow_estimation(i,j,2);
            %Check if indexes are out of the image
            if new_i<1
               new_i=1;
            end
            if new_j<1
               new_j=1;
            end
            if new_i>ni
               new_i=ni;
            end
            if new_j>nj
               new_j=nj;
            end
            comp_im(i,j) = frame2(new_i, new_j);
        end
    end    
end

