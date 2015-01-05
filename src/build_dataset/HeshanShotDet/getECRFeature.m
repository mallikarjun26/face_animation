% This function is used to read frame image of a video and calculate the
% distance function based on ECR. It take the frame filename's prefix 
% and the total framenumber as input parameter.

function [featureA] = getHistogramFeature(imageFileNamePrefix, frame_num)

featureA = [];
% read frame image and calculate the distance function
%   read first frame
fileName = strcat(imageFileNamePrefix,num2str(1),'.bmp');
im = imread(fileName);
imd = rgb2gray(im);
bw1 = edge(imd, 'sobel'); % black background

for i = 2: frame_num
	fileName = strcat(imageFileNamePrefix,num2str(i),'.bmp');
	im = imread(fileName);
	imd = rgb2gray(im);
	bw2 = edge(imd, 'sobel'); % black background
	ibw2 = 1-bw2; % white background

    ibw1 = 1-bw1; % white background
    
    % calculate the ECR
    s1 = size(find(bw1),1);
    s2 = size(find(bw1),1);

    se = strel('square',3);
    dbw1 = imdilate(bw1, se);
    dbw2 = imdilate(bw2, se);

    imIn = dbw1 & ibw2;
    imOut = dbw2 & ibw1;
    
    ECRIn = size(find(imIn),1)/s2;
    ECROut = size(find(imOut),1)/s1;
    
    ECR = max(ECRIn, ECROut);
    featureA = [featureA; i ECR];
    bw1 = bw2;
end

return;