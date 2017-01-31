function gif_horizontal_plots(directory_results,gif_name,plot_frames,titles,i)
%Creates gif with horizontal subplots
%   plot_frames: cell containing the frames of the different subplots
%   titles: cell containing subplots titles

    nplots=length(titles);
    for j=1:nplots
        subplot(1,nplots,j);
        imshow(plot_frames{j});
        title(titles{j})
    end
    
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);
    if i == 1
        imwrite(imind,cm,[directory_results,filesep,gif_name],'gif','DelayTime',0,'Loopcount',inf);
    else
        imwrite(imind,cm,[directory_results,filesep,gif_name],'gif','DelayTime',0,'WriteMode','append');
    end
end