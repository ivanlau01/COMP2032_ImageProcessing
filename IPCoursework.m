clc,
clear all,
close all,
workspace;  % Make sure the workspace panel is showing.

% Read Image
plant{1} = imread('plant001.png');
plant{2} = imread('plant002.png');
plant{3} = imread('plant003.png');

% Display 3 images using for loop
for i = 1 : 3
    
    %% 1- Convert image to grayscale
    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/matlabcentral/answers/119804-greenness-of-an-rgb-image
    % Gets the grayscale arrays of each of the RGB channels of the Plant.
    % Converts the values to double and prepare for normalisation. 
    R = double(plant{i}(:,:,1));
    G = double(plant{i}(:,:,2));
    B = double(plant{i}(:,:,3));

    % Normalise values (0 = 0, 1 = 255) which avoids overflows
    R = R/255;
    G = G/255;
    B = B/255;

    % Greeness using normalised doubles
    greeny = (G - (R + B)/2.0);

    %% 2- Image pre-processing
    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/medfilt2.html
    % Try to remove the noise with Median filters
    fixedWithMedian = medfilt2(greeny);
    
    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/imbinarize.html
    % Creates a binary image from the plant using the thresholding method.
    % The method is specified as 'global'
    BW = imbinarize(fixedWithMedian, 'global');
    
    %% 3-  Morphological operations
    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/imdilate.html
    % Make a disk structuring element with a radius of 1.0
    se = strel('disk', 1.0);

    % Dilates grayscale, binary or packed binary image of BW using the structuring element of se
    BW2 = imdilate(BW, se);

    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/bwareafilt.html
    % Retaining only objects with area of 1 biggest object
    BW3 = bwareafilt(BW2, 1);
    
    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/bwareaopen.html
    % Remove all of the small objects from binary image that has less than 20 pixels
    BW4 = ~bwareaopen(~BW3, 20);
    
    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/bwdist.html
    % For each pixel in BW4, the distance transform assigns a number that is the distance between that pixel and the nearest nonzero pixel of BW4
    D = -bwdist(~BW4);
    
    %% 4- Watershed segmentation
    % Watershed technique is applied
    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/imextendedmin.html
    mask = imextendedmin(D, 2);

    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/imimposemin.html 
    D2 = imimposemin(D, mask);

    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/watershed.html
    ws = watershed(D2);
    BW4(ws == 0) = 0;
    
    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/bwlabel.html
    L = bwlabel(BW4);
    
    %% 5- Assign random colours to the leaves and show output image
    % Code adapted from Matlab & Simulink example:
    % To get the number of maximum labels from the 3 segmentation and randomise a cmap matrix
    numlabels = max(plant{i}(:));
    maxlabels = max(numlabels);
    map = rand(maxlabels, 3);
    
    % Code adapted from Matlab & Simulink example: https://www.mathworks.com/help/images/ref/label2rgb.html
    % assign random colour to the leaves and display them in black background 
    Lrgb = label2rgb(L , map , 'k', 'shuffle');
    
    % Image output
    subplot(2,3,i)
    imshow(plant{i})
    title(sprintf("Plant %d",i))

    subplot(2,3,i+3)
    imshow(Lrgb)
    title("Image Output")

end