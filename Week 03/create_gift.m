function []=create_gift(image,foreground,foregroundfilled,foregroundprocessed,filename,i)

subplot(141);
imshow(image);
subplot(142),
imshow(foreground,[]);
subplot(143),
imshow(foregroundfilled,[]);
subplot(144),
imshow(foregroundprocessed,[]);

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