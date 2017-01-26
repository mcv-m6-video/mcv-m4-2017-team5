function []=create_gift(image,foreground,filename,i)

subplot(121);
imshow(image);
subplot(122),
imshow(foreground,[]);
%   subplot(2,2,[3 4]);
%   plot(1:length(dirIn),FMeasure);
%   axis([0 200 0 1])

frame = getframe(gcf);
im=frame2im(frame);
[imind,cm]=rgb2ind(im,256);

    % On the first loop, create the file. In subsequent loops, append.
    if i==1
        imwrite(imind,cm,filename,'gif','DelayTime',0,'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','DelayTime',0,'WriteMode','append');
    end
end