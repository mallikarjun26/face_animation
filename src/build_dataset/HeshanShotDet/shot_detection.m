% This function takes the avi filename as input and detect hard cuts.

function [featureHist, cutHist]=shot_detection(aviFileName, outputFolder)

%{
% extact frames from video and output them as bmp files
disp('extact frames from video and output them as jpg files');
movieObj = VideoReader(aviFileName);
%noOfFrameImages = size(movieObj,2);
noOfFrameImages = movieObj.NumberOfFrames;
disp(['Number of frames in the video:' num2str(noOfFrameImages) ]);

% Collecting frames
disp('Collecting frames');
for count=1:1:noOfFrameImages
    imageFileNamePrefix = strcat(outputFolder, '/all_frames/framedump_');
    fileName = strcat(imageFileNamePrefix,num2str(count),'.jpg');
    %imwrite(   movieObj(count).cdata    ,fileName,'bmp');    
    imwrite(read(movieObj, count), fileName, 'jpg');    
end

%}

imageFileNamePrefix = strcat(outputFolder, '/all_frames/framedump_');
noOfFrameImages = 199464;
% calculate fetures values based on histogram dissimilarity
disp('calculate fetures values based on histogram dissimilarity');
featureHist = getHistogramFeature(imageFileNamePrefix, noOfFrameImages);

% calculate fetures values based on ECR
%disp('calculate fetures values based on ECR');
%featureECR = getECRFeature(imageFileNamePrefix, noOfFrameImages);

% detect hard cuts use adaptive threshold
disp(' detect hard cuts use adaptive threshold');
cutHist = cutDetect(featureHist);
%cutECR = cutDetect(featureECR);

%% write into the file frame number and the shot number 
disp('write into the file frame number and the shot number ');
outputFileName = strcat(outputFolder, '/frameShotMap.txt');
frameShotMapHandle = fopen(outputFileName, 'w');

startFrame = 0;
for i=1:size(cutHist,1)
    stopFrame = cutHist(i,1)-1;
    shotNo = i-1;
    fprintf(frameShotMapHandle, [num2str(startFrame) '-' num2str(stopFrame) '=' num2str(shotNo) '\n']);
    startFrame = cutHist(i,1);
end
fclose(frameShotMapHandle);

%% plot the result
disp('plot the result');
figure; plot(featureHist(:,1),featureHist(:,2)); 
xlabel('Frame Number'); ylabel('Histogram Feature Value'); 
hold; plot(cutHist(:,1),cutHist(:,2),'rx'); legend('f(n)', 'cut');

%figure; plot(featureECR(:,1),featureECR(:,2)); 
%xlabel('Frame Number'); ylabel('ECR Feature Value'); 
%hold; plot(cutECR(:,1),cutECR(:,2),'rx'); legend('f(n)', 'cut');

return;
