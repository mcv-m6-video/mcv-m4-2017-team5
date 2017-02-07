files = dir('*.jpg');
N=24;
nframe=127;
writerObj = VideoWriter( 'traffic.avi' );
writerObj.FrameRate = N;
open(writerObj);
figure;
for i=1:numel(files) %number of images to be read
     
     
     input = imread(files(i).name);

     % Write frame now
     writeVideo(writerObj, input);
end
close(writerObj);