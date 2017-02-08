Mv = VideoReader('../Database/Week02/trafficvideo/traffic.avi');
rmin = 0; %min row value for search window
rmax = 0; %max row value for search window
cmin = 0; %min col value for search window
cmax = 0; %max col value for search window
numofframes = 0;
frameNo = 1; %starting frame
vidSize=[240 320]; %video size
centerold = [0 0];
centernew = [0 0];

M =Mv;

% get number of frames
numberofframes = length(M);

Frame1 = M(frameNo);
Image1 = imresize(Frame1.cdata,vidSize,'bilinear');
disp('Click and drag mouse for an initial box window');
% get search window for first frame
[ cmin, cmax, rmin, rmax ] = select( Image1 );
cmin = round(cmin);
cmax = round(cmax);
rmin = round(rmin);
rmax = round(rmax);
wsize(1) = abs(rmax - rmin);
wsize(2) = abs(cmax - cmin);

hue=Image1(:,:,1);
histogram = zeros(256);

for i=rmin:rmax
for j=cmin:cmax
index = uint8(hue(i,j)+1);
%count number of each pixel
histogram(index) = histogram(index) + 1;
end
end

% for each frame
for i = frameNo:numberofframes
Frame = M(i);
I = imresize(Frame.cdata,vidSize,'bilinear');

hue= I(:,:,1);
[rows cols] = size(hue);
probmap = zeros(rows, cols);
for r=1:rows
for c=1:cols
if(hue(r,c) ~= 0)
probmap(r,c)= histogram(hue(r,c));
end
end
end
probmap = probmap/max(max(probmap));
probmap = probmap*255;

count = 0;

rowcenter = 0; % any number just so it runs through at least twice
colcenter = 0;
rowcenterold = 30;
colcenterold = 30;
while (((abs(rowcenter - rowcenterold) > 2) && (abs(colcenter - colcenterold) > 2)) || (count < 15) )
rowcenterold = rowcenter;
colcenterold = colcenter;

[ rowcenter colcenter M00 ] = meanshift(rmin, rmax, cmin,...
cmax, probmap);

rmin = round(rowcenter - wsize(1)/2);
if rmin<1
rmin=1;
end
rmax = round(rowcenter + wsize(1)/2);
if rmax<1
rmax=1;
end
cmin = round(colcenter - wsize(2)/2);
if cmin<1
cmin=1;
end
cmax = round(colcenter + wsize(2)/2);
if cmax<1
cmax=1;
end
wsize(1) = abs(rmax - rmin);
wsize(2) = abs(cmax - cmin);

count = count + 1;
end

G = I;
trackim=G;

%make box of current search window on saved image
for r= rmin:rmax
trackim(r, cmin:cmin+2) = 0;
trackim(r, cmax-2:cmax) = 0;
end
for c= cmin:cmax
trackim(rmin:rmin+2, c) = 0;
trackim(rmax-2:rmax, c) = 0;
end

windowsize = 100 * (M00/256)^.5;
sidelength = sqrt(windowsize);
rmin = round(rowcenter-sidelength/2);
if rmin<1
rmin=1;
end
rmax = round(rowcenter+sidelength/2);
if rmax<1
rmax=1;
end
cmin = round(colcenter-sidelength/2);
if cmin<1
cmin=1;
end
cmax = round(colcenter+sidelength/2);
if cmax<1
cmax=1;
end
wsize(1) = abs(rmax - rmin);
wsize(2) = abs(cmax - cmin);


outname = sprintf('./answer/%d.jpg', i);
imwrite(trackim, outname);

figure(1),imshow(trackim); hold on
end