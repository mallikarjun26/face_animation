function [ featureVectors ] = edgeWieghtCalculator( inputPath )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%{
    init;
    noOfFaces   = 0;
    listOfFaces = {};

    disp(cputime);
    %% Collect list of all participating faces
    inputFileHandler = fopen( strcat(inputPath, '/../', 'ListOfFaces.txt'), 'r' );
    tLine = fgetl(inputFileHandler);
    firstRow = true;
    while ischar(tLine) 
        %disp(tLine);
        noOfFaces = noOfFaces + 1;
        
        if(firstRow == true)
            %disp(tLine)
            tLineSplit = strsplit(tLine);
            disp(tLineSplit(1));
            listOfFaces{noOfFaces} = tLineSplit(1);
            firstRow = false;
        else
            tLineSplit = strsplit(tLine);
            listOfFaces{noOfFaces} = tLineSplit(1);
        end
        
        tLine = fgetl(inputFileHandler);    
    end
    
    disp(noOfFaces);
    %disp(size(listOfFaces));
    %disp(listOfFaces);
    
    disp(cputime);
    %% Feature vector calculation
    outputFileHandler = fopen( strcat(inputPath, '/../', 'featureVectors.txt'), 'w' );
    fprintf(outputFileHandler, num2str(noOfFaces));
    fprintf(outputFileHandler, '\n');
    for i=1:noOfFaces 
        image_1 = strcat(inputPath, '/', listOfFaces{i});
        %disp(image_1);
        [DETS_1,PTS_1,DESCS_1]=findFiducialPoints(opts,image_1{1},false);
        disp(listOfFaces{i});
        strTemp = strcat(num2str(i-1), '=');
        for j=1:size(DESCS_1-1) 
            strTemp = strcat(strTemp, num2str(DESCS_1(j)), ':');
        end
        strTemp = strcat(strTemp, num2str(DESCS_1(j)), '\n');
        fprintf(outputFileHandler, strTemp);
    end
    fclose(outputFileHandler);
    
   
%}


    %% Edge weights detection
    inputFileHandler = fopen( strcat(inputPath, '/../', 'featureVectors.txt'), 'r' );
    %featureVectors = [];
    tLine = fgetl(inputFileHandler);
    if ischar(tLine) 
        noOfFaces = str2num(tLine);
    end
    delimiter = {'=',':'};
    faceNo = 0;
    tLine = fgetl(inputFileHandler);
    while ischar(tLine) 
        %disp(tLine);
        faceNo = faceNo + 1;
        tLineSplit = strsplit(tLine,delimiter);
        %disp(size(tLineSplit));
        for i=1:size(tLineSplit,2)-1
            featureVectors(faceNo, i) = str2double(tLineSplit(1,i+1));
        end
        tLine = fgetl(inputFileHandler);    
    end
  

    disp('Collected all the feature Vectors ');
    
    outputFileHandler = fopen( strcat(inputPath, '/../', 'edgeWeights.txt'), 'w' );
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
    
 
    disp(size(featureVectors));
   
    
    %%
%     %% Find the edge weights between all faces and write it in a file.
%     outputFileHandler = fopen( strcat(inputPath, '/../', 'edgeWeights.txt'), 'w' );
%     edgeEnd   = 1;
%     edgeStart = 1;
%    
%     strTemp = strcat(num2str(noOfFaces), '\n');
%     fprintf(outputFileHandler, strTemp);
%     
%     for i=edgeStart:5  %noOfFaces-1
%         edgeEnd = edgeEnd +1;
%         for j=edgeEnd:6  %noOfFaces
%             image_1 = strcat(inputPath, '/', listOfFaces{i});
%             image_2 = strcat(inputPath, '/', listOfFaces{j});
%             euclideanDistance = findSimilarityScore(image_1{1}, image_2{1});
%             disp(euclideanDistance);
%             strTemp = strcat(num2str(i), '-', num2str(j), '=', num2str(euclideanDistance), '\n');
%             %strTemp = strcat(listOfFaces{i}, '-', listOfFaces{j}, '=', num2str(euclideanDistance), '\n');
%             fprintf(outputFileHandler, strTemp);
%         end    
%     end
%     
%     fclose(outputFileHandler);
end

