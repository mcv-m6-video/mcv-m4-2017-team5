path_files='../../Results/week5\custom_video4\motion';
files = dir([path_files '/*.png']);
N = 24;

writerObj = VideoWriter( '../v4_motion.avi' );
writerObj.FrameRate = N;
open(writerObj);
figure;
for i=1:numel(files) %number of images to be read
     
     
     input = imread([path_files filesep files(i).name]);

     % Write frame now
     writeVideo(writerObj, input);
end
close(writerObj);