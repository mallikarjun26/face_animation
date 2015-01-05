function [featureVectors, bs] = ESmain(inputPath)

% compile.m should work for Linux and Mac.
% To Windows users:
% If you are using a Windows machine, please use the basic convolution (fconv.cc).
% This can be done by commenting out line 13 and uncommenting line 15 in
% compile.m
compile;

% load and visualize model
% Pre-trained model with 146 parts. Works best for faces larger than 80*80
%load face_p146_small.mat

% % Pre-trained model with 99 parts. Works best for faces larger than 150*150
 load face_p99.mat

% % Pre-trained model with 1050 parts. Give best performance on localization, but very slow
% load multipie_independent.mat

% 5 levels for each octave
model.interval = 5;
% set up the threshold
model.thresh = min(-0.65, model.thresh);

% define the mapping from view-specific mixture id to viewpoint
if length(model.components)==13
    posemap = 90:-15:-90;
elseif length(model.components)==18
    posemap = [90:-15:15 0 0 0 0 0 0 -15:-15:-90];
else
    error('Can not recognize this model');
end


%% Collect List of faces and find the feature vectors for each of them and store in a file

% Collect face's frame number along with the bounding box details
disp('Collect faces frame number along with the bounding box details');
noOfFaces = 0;
mapOfFaces = containers.Map();
faceListFileHandler = fopen( strcat(inputPath, '/ListOfFaces.txt'), 'r' );
tLine = fgetl(faceListFileHandler);

delimiter = {'.',' '};
while ischar(tLine)
    %disp(tLine);
    tFileNameWoJpg = strsplit(tLine, delimiter);
    %disp(tFileNameWoJpg(1));
    t_int = tFileNameWoJpg(1);
    %disp(t_int{1});
    mapOfFaces(t_int{1}) = noOfFaces;
    noOfFaces = noOfFaces + 1;
    tLine = fgetl(faceListFileHandler);
end

% Load the image with increased bounding box
% Call detect function and collect the part's bounding boxes and angle
% Concatenate the (HOG)feature vectors for each of the bounding boxes
% Dump the features in the file
roiFileHandler = fopen( strcat(inputPath, '/ROI.txt'), 'r' );
tLine = fgetl(roiFileHandler);
featuresFileHandler = fopen( strcat(inputPath, '/featureVectors.txt'), 'w' );
feat = [];
delimiter = {' '};
delimiter_ = {'_'};

fprintf(featuresFileHandler, num2str(noOfFaces));
fprintf(featuresFileHandler,'\n');
count = 0;

disp('Load the image with increased bounding box');
while ischar(tLine)
    tLineSplit = strsplit(tLine, delimiter);
    %disp(tLineSplit(1));
    if(isKey(mapOfFaces, tLineSplit(1)))
        count = count +1;
        faceNo =  tLineSplit{1};
        disp(faceNo);
        frameNoList = strsplit(faceNo, delimiter_);
        frameNo = frameNoList{1};
        %disp(frameNo);
        imgName = strcat(inputPath, '/Frames/', frameNo, '.jpg');
        disp(imgName);
%         disp(tLineSplit(2));
%         disp(tLineSplit(3));
%         disp(tLineSplit(4));
%         disp(tLineSplit(5));
%         disp(tLineSplit(6));
%    

        im = imread(imgName);
        imagesc(im);
        x1_o =  str2num(tLineSplit{2});
        y1_o =  str2num(tLineSplit{3});
        width   = str2num(tLineSplit{5});
        height = str2num(tLineSplit{4});
        
        x1 =  round(   x1_o  - (width * 0.2)  );
        x2 =  round(   (x1_o+ width) + (width * 0.2)  );
        y1 =  round(     y1_o  -   (height*0.2) )  ;
        y2 =  round(    (y1_o + height)   + (height*0.2)   );
        
        x1 = max(x1, 1);
        x2 = min(x2, size(im,2));
        y1 = max(y1, 1);
        y2 = min(y2, size(im,1));
        
        ROWS = [y1 y2];
        COLS   = [x1 x2];
        %disp(imgName{1});
        %im = imread(imgName{1}, 'PixelRegion', {ROWS, COLS});

        %disp(size(im));
        %disp(x1);disp(x2);disp(y1);disp(y2);
        
        im = im(y1:y2, x1:x2, :);
        im = imresize(im, [200 200]);
        imagesc(im);
        % Call detect function and collect the part's bounding boxes and angle
        disp(size(im));
        disp('Calling detect function on bounded image');
        bs = detect(im, model, model.thresh);
        bs = clipboxes(im, bs);
        bs = nms_face(bs,0.3);

        %bs1(count) = bs;
       
        % show highest scoring one
       %figure,showboxes(im, bs(1),posemap),title('Highest scoring detection');
       % show all
        %figure,showboxes(im, bs,posemap),title('All detections above the threshold');
    
        %disp('press any key to continue');
        %pause; 
        
        % Concatenate the (HOG)feature vectors for each of the bounding boxes
        disp('Concatenate the (LBP)feature vectors for each of the bounding boxes');
        clear featuresStr
        clear feat;
        feat= '';
        %disp(length(bs.xy));
        %pause;
        
        if(isempty(bs))
            disp('Damn its empty!');
            tLine = fgetl(roiFileHandler);
            continue;
        end
        
        featuresStr = num2str(mapOfFaces(tLineSplit{1}));
        featuresStr = strcat(featuresStr, ',', num2str(bs.c), '=');
        fprintf(featuresFileHandler, featuresStr );
        
        for i=1:length(bs.xy)
            x1 = floor(bs.xy(i,1));
            y1 = floor(bs.xy(i,2));
            x2 = floor(bs.xy(i,3));
            y2 = floor(bs.xy(i,4));
            
            %disp(x1); disp(x2); disp(y1); disp(y2);
            %disp(size(im));
            
            part = im(x1:x2, y1:y2, :);
            part = rgb2gray(part);
            part = single(part);
            part = imresize(part, [20 20]);
            %part = double(part);
            %disp(size(part));
            %tFeat = features(part, model.sbin);
            %tFeat = vl_hog(im2single(part), 7);
            tFeat = vl_lbp(part, 7);
            
            %disp(size(tFeat));
            tSize = size(tFeat, 1) * size(tFeat, 2) * size(tFeat, 3);
            tFeat = reshape(tFeat, 1, tSize);
            fprintf(featuresFileHandler,'%g ',tFeat(1,:));
            if(i ~= length(bs.xy))
                fprintf(featuresFileHandler,';');
            end
            %disp(tFeat);
            feat = [feat tFeat];
            %feat = [feat, num2str(tFeat), ';'];
        end
        %feat = feat(1:end-1);
        
    
        disp(size(feat));
        %fprintf(featuresFileHandler,'%g:',feat(1,:));
        %fprintf(featuresFileHandler, feat);
        fprintf(featuresFileHandler,'\n');
        %dlmwrite( strcat(inputPath, '/features_68pt.txt'), feat);
        
%         disp(mapOfFaces(tLineSplit{1}));
%         featuresStr = num2str(mapOfFaces(tLineSplit{1}));
%         featuresStr = strcat(featuresStr, ':', num2str(bs.c), '=');
%         
%         for i =1:size(feat, 2)-1
%             featuresStr = strcat(featuresStr, num2str(feat(1, i)),',');
%         end
%         featuresStr = strcat(featuresStr, num2str(feat(1, size(feat,2))));
        %disp('Done concatenating state 2!');
        
        disp('Writing the features into the file');
        %fprintf( featuresFileHandler, featuresStr);
        disp('Debug 00');
    end
    tLine = fgetl(roiFileHandler);
end
fclose(featuresFileHandler);


% Store the same in a file.  Format
% Line 1 - Number of faces.
% Line 2-n - face id, Angle, Feature Vector

%{

%% Find edge weights.

    disp('Collecting features from the file');
    inputFileHandler = fopen( strcat(inputPath, '/featureVectors.txt'), 'r' );
    %featureVectors = [];
    tLine = fgetl(inputFileHandler);
    if ischar(tLine) 
        noOfFaces = str2num(tLine);
    end
    delimiter = {',','=',':'};
    faceNo = 0;
    tLine = fgetl(inputFileHandler);
    while ischar(tLine) 
        %disp(tLine);
        %faceNo = faceNo + 1;
        
        tLineSplit = strsplit(tLine,delimiter);
        faceNo = str2num(tLineSplit{1,1});
        
        %disp(size(tLineSplit));
        for i=1:size(tLineSplit,2)-3
            featureVectors(faceNo+1, i) = str2double(tLineSplit(1,i+2)); %faceNo+1 because of matlab thing. later incremented while writing into edgeWeights file.
        end
        tLine = fgetl(inputFileHandler);    
    end
  
    disp('Finding the edge weights');
    
    outputFileHandler = fopen( strcat(inputPath, '/edgeWeights.txt'), 'w' );
    strTemp =  strcat(num2str(noOfFaces), '\n');
    fprintf(outputFileHandler, strTemp);
    edgeEnd = 1;
    for i=1:noOfFaces-1
        disp('Debug inside first for \n');
        edgeEnd = edgeEnd + 1;
        for j=edgeEnd:noOfFaces
           euclideanDistance = pdist([featureVectors(i,:); featureVectors(j,:)]); 
           strTemp = strcat(num2str(i-1), '-', num2str(j-1), '=', num2str(euclideanDistance), '\n');
           fprintf(outputFileHandler, strTemp);
        end
    end
    fclose(outputFileHandler);
    
 
    %disp(size(featureVectors));
%}

end





















