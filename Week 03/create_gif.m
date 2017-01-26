function []=create_gif(image,foreground,foregroundfilled,filename,i)

subplot(131);
imshow(image);
subplot(132),
imshow(foreground,[]);
subplot(133),
imshow(foregroundfilled,[]);

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