function cols = error_colormap ()
%First two columns: interval for histogram
%Other columns: RGB color for each bar of histogram
cols = [ 0,       0.1875,  49,  54, 149;
         0.1875,  0.375,   69, 117, 180;
         0.375,   0.75,   116, 173, 209;
         0.75,    1.5,    171, 217, 233;
         1.5,     3,      224, 243, 248;
         3,       6,      254, 224, 144;
         6,      12,      253, 174,  97;
        12,      24,      244, 109,  67;
        24,      48,      215,  48,  39;
        48,     inf,      165,   0,  38 ];
      
cols(:,3:5) = cols(:,3:5)/255;
end