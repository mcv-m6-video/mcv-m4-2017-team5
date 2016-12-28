function plot_mean_optical_flow (Image,Optical_flow,rSize,scale,name)
%Plots optical flow showing the mean optical flow for each region
    mean_optical_flow=Optical_flow;
    H = fspecial('average',rSize);
    
    u = imfilter(Optical_flow(:,:,1),H);
    v = imfilter(Optical_flow(:,:,2),H);
    u(mean_optical_flow(:,:,3)==0)=0;
    v(mean_optical_flow(:,:,3)==0)=0;

    mean_optical_flow(:,:,1)=u;
    mean_optical_flow(:,:,2)=v;
    plot_optical_flow (Image,mean_optical_flow,rSize,scale,name);
end