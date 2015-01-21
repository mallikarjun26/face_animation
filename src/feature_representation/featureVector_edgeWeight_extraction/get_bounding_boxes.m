function get_bounding_boxes(inputPath)

    bounding_boxes_file = [inputPath '/intermediate_results/bounding_boxes.mat'];

    compile;

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

    roiFileHandler = fopen( strcat(inputPath, '/ROI/ROI.txt'), 'r' );
    tLine = fgetl(roiFileHandler);

    delimiter = {' '};
    delimiter_ = {'_'};

    count = 0;

    disp('Load the image with increased bounding box');
    while ischar(tLine)
        tLineSplit = strsplit(tLine, delimiter);
        %disp(tLineSplit(1));
        if(isKey(mapOfFaces, tLineSplit(1)))
            count = count +1;
            faceNo =  tLineSplit{1};
            frameNoList = strsplit(faceNo, delimiter_);
            frameNo = frameNoList{1};
            imgName = strcat(inputPath, '/Frames/', frameNo, '.jpg')
            
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
            
            im = im(y1:y2, x1:x2, :);
            im = imresize(im, [200 200]);
            imagesc(im);
            % Call detect function and collect the part's bounding boxes and angle
            disp(size(im));
            disp('Calling detect function on bounded image');
            bs = detect(im, model, model.thresh);
            bs = clipboxes(im, bs);
            bs = nms_face(bs,0.3);

            if(~isempty(bs))
                node_number = uint8(mapOfFaces(faceNo)) + uint8(1);
                bounding_boxes{node_number} = bs;
            end

        end
        tLine = fgetl(roiFileHandler);
    end

    save(bounding_boxes_file, 'bounding_boxes');
    
end