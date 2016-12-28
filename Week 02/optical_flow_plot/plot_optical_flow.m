function plot_optical_flow (Image,Optical_flow,rSize,scale,name)
%Plots optical flow showing only one vector for each region
    s=size(Optical_flow);
    [x,y] = meshgrid(1:s(2),1:s(1));
    u=Optical_flow(:,:,1);
    v=Optical_flow(:,:,2);

    % Show one vector per region
    for i=1:size(u,1)
        for j=1:size(u,2)
            if floor(i/rSize)~=i/rSize || floor(j/rSize)~=j/rSize
                u(i,j)=0;
                v(i,j)=0;
            end
        end
    end

    %Remove points with 0 optical flow
    x(u==0&v==0)=0;
    y(u==0&v==0)=0;

    f = figure();
    imshow(Image);
    hold on;
    quiver(x, y, u, v, scale, 'color', 'g', 'linewidth', 1);
    saveas(f, name);
end