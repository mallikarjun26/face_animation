% Given feature vectors for each face, it finds the edge weight between faces by considering pose and finding the common fiducial points between faces.

function [commonPartsMap, filtersList, faceFeatureMap] = findCommonParts(model, inputPath)
     
    noOfComponentsInEachPartVector = 2*2*58;
    
    %% Initialization
    numberOfComponents     = length(model.components);
    filtersList                                   = cell(numberOfComponents,1);
    commonPartsMap                = containers.Map;
    
    %% Get the part filter ids for each components(pose)
    for i=1:numberOfComponents
        tempStruct = model.components{i};
        filtersList(i,1) = { reshape([tempStruct.filterid], size(tempStruct)) };
    end
    
    %disp(filtersList);
    
    %% Find the common parts between combination of poses
    for i=1:numberOfComponents-1
        tempArray = intersect(filtersList{i}, filtersList{i});
        tempKey     = strcat(num2str(i), '-', num2str(i));
        commonPartsMap(tempKey) = tempArray;
        j=i+1;
        tempArray = intersect(filtersList{i}, filtersList{j});
        tempKey     = strcat(num2str(i), '-', num2str(j));
        commonPartsMap(tempKey) = tempArray;
        
        if(i==numberOfComponents-1)
           
        elseif(i==numberOfComponents-2)
            j=i+2;
            tempArray = intersect(filtersList{i}, filtersList{j});
            tempKey     = strcat(num2str(i), '-', num2str(j));
            commonPartsMap(tempKey) = tempArray;
            
        else
            j=i+2;
            tempArray = intersect(filtersList{i}, filtersList{j});
            tempKey     = strcat(num2str(i), '-', num2str(j));
            commonPartsMap(tempKey) = tempArray;
             j=i+3;
            tempArray = intersect(filtersList{i}, filtersList{j});
            tempKey     = strcat(num2str(i), '-', num2str(j));
            commonPartsMap(tempKey) = tempArray;
           
        end
    end
    %disp(commonPartsMap);
    
   %% Collect the featureVectors into main memory to find the edge weights later
    
    disp('Collecting features from the file');
    disp(strcat(inputPath, '/featureVectors.txt'));
    featureVectorsFileHandler = fopen( strcat(inputPath, '/featureVectors.txt'), 'r' );
    faceFeatureMap = containers.Map('KeyType', 'single', 'ValueType', 'any');
    
    entireLine = fgetl(featureVectorsFileHandler);
    if ischar(entireLine) 
        noOfFaces = str2double(entireLine);
    end
    
    %delimiter = {',','=',';'};
    delimiter = {',','=',';',' '};
    entireLine = fgetl(featureVectorsFileHandler);
    
    loopCount = 0;
    
    while ischar(entireLine) 
        
        loopCount = loopCount + 1;
        tic
        lineSplit             =   strsplit(entireLine,delimiter);
        %disp(['Time to split feature line' num2str(toc)]);
        tic
        faceNumber   =   str2double(lineSplit{1,1});
        disp(['Getting features: ' num2str(faceNumber) ' (' num2str(loopCount) '/' num2str(noOfFaces) ')' ]);
        componentNumber  = str2double(lineSplit{1,2});
        
        partsMap = containers.Map('KeyType', 'single', 'ValueType', 'any');
   
        
        noOfParts = size(filtersList{componentNumber},2);
        tempNoOfPartsInLine = (size(lineSplit,2) - 3) / noOfComponentsInEachPartVector; 
      
        if( noOfParts ~= tempNoOfPartsInLine )
            error('Number of parts is not correct, Expected: ', noOfParts, ' Actual:', tempNoOfPartsInLine);
        else
            %disp(['Expected: ' num2str(noOfParts) 'Actual:' num2str(tempNoOfPartsInLine)]);
            partFeatureSize = noOfComponentsInEachPartVector;
            for i=1:noOfParts
                partNumber                            =   single(filtersList{componentNumber, 1}(1, i));

                tempPartFeatureVector   = zeros(1, partFeatureSize);
                for j=1:partFeatureSize % iterating over features of each part
                    index = (2)  +  ((i-1) *  partFeatureSize) + j   ;
                    tempPartFeatureVector(1, j) = str2double(lineSplit(1, index));
                end
                
                partsMap(partNumber)     =  tempPartFeatureVector;
            end
            
        end
       
      
    %{
        for j=3:length(lineSplit) %iterating over all parts
            
            partNumber                            =   single(filtersList{componentNumber, 1}(1, j-2));

            partFeatureVector              =   strsplit(lineSplit{1, j}, ' ');
            %disp(['Time to second split' num2str(toc)]);
            partFeatureSize                    =   size(partFeatureVector, 2) - 1;

            tempPartFeatureVector   = zeros(1, partFeatureSize);
            for i=1:partFeatureSize % iterating over features of each part
                tempPartFeatureVector(1, i) = str2double(partFeatureVector(1, i));
            end
            partsMap(partNumber)     =  tempPartFeatureVector;
            
        end
    %}

        
        s = struct('component', componentNumber, 'parts', partsMap);
        faceFeatureMap(faceNumber) = s;
        entireLine = fgetl(featureVectorsFileHandler);
        %disp(['Time elapsed for one face feature vector process: ' num2str(toc)]);
    end
    
    
   %% Find edge weights between the faces based on top 15 matching parts 
    disp('Find edge weights between the faces based on top 15 matching parts ');
    edgeWeightsFileHandler = fopen( strcat(inputPath, '/edgeWeights.txt'), 'w' );
    fprintf(edgeWeightsFileHandler, num2str(loopCount));
    fprintf(edgeWeightsFileHandler, '\n');
    faceKeys = faceFeatureMap.keys;
    
    for i=1:length(faceKeys)-1
        disp(['Edge weight calculation loop: ' '(' num2str(i) '/' num2str(length(faceKeys)-1) ')'  ]);
        nextFace = i+1;
        faceNo_1 = single(faceKeys{1,i});
        compNo_1 = faceFeatureMap(faceNo_1).component;
        partMap_1 = faceFeatureMap(faceNo_1).parts;
        parfor j=nextFace:length(faceKeys)
            tic
            
            faceNo_2 = single(faceKeys{1,j});
            
            compNo_2 = faceFeatureMap(faceNo_2).component;
            
            tempLookUp = [num2str(min(compNo_1,compNo_2)) '-' num2str(max(compNo_1,compNo_2))];
            if(commonPartsMap.isKey(tempLookUp)) 
                
                tempCommonArray = commonPartsMap(tempLookUp);
                tempPartDistMap = containers.Map('KeyType', 'double', 'ValueType', 'single');
                
                partMap_2 = faceFeatureMap(faceNo_2).parts;
                for k=1:length(tempCommonArray)
                    tempPartNumber = tempCommonArray(1,k);
                    tempDistMat = [partMap_1(tempPartNumber) ; partMap_2(tempPartNumber) ];
                    tempPartDist = pdist(tempDistMat);
                    tempPartDistMap(tempPartDist) = tempPartNumber;
                end
            
                %Select top 15 most similar parts for final distance calculation
                sortPartDist = tempPartDistMap.keys;
                finalDist = 0;
                for m=1:15
                    finalDist = finalDist + sortPartDist{1,m};
                end
                
                tempOline = strcat(num2str(faceNo_1), '-', num2str(faceNo_2), '=', num2str(finalDist));
                fprintf(edgeWeightsFileHandler, tempOline);
                fprintf(edgeWeightsFileHandler, '\n');
                
            end
            %toc
        end
    end
    fclose(edgeWeightsFileHandler);
    
    
end
