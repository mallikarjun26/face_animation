function wastes = extend_face_bb(input_path)

    %
    load([input_path '/intermediate_results/facemap.mat']);
    
    %
    face_size = [300 300];
    frames_folder = [input_path '/Frames/'];
    faces_folder = [input_path '/faces/'];
    fid = fopen([input_path '/ROI/ROI.txt']);
    roi = textscan(fid, '%s %u %u %u %u');
    face_id = roi{1,1};
    keys = {face_id{:}};
    values = [1:size(face_id,1)];
    all_frames_map = containers.Map(keys, values);
    x = roi{1,2};
    y = roi{1,3};
    w = roi{1,4};
    h = roi{1,5};
    per_inc_each_side = 0.3;
    wastes = 0;
    
    number_of_nodes = size(facemap, 2);
    id_begin = max( find(facemap{1} == '/' ) ) + 1;
    
    for i=1:number_of_nodes
        
        if(mod(i,100) == 0)
            disp([num2str(i) '/' num2str(number_of_nodes) 'nodes done']); 
        end
        
        temp_face_id = facemap{i}(id_begin:end-4);
        row = all_frames_map(temp_face_id);
        
        t_im = imread([frames_folder temp_face_id(1:end-2) '.jpg']);
        
        x1 = x(row,1) - ( w(row,1) * per_inc_each_side );
        y1 = y(row,1) - ( h(row,1) * per_inc_each_side );
        x2 = x(row,1) + w(row,1) + ( w(row,1) * per_inc_each_side );
        y2 = y(row,1) + h(row,1) + ( h(row,1) * per_inc_each_side );
        width = size(t_im, 2);
        hieght = size(t_im, 1);
        
        if ( (x1<1) || (y1<1) || (x2>width-1) || (y2>hieght-1) )
            wastes = wastes +1;
            x1 = max(1, x(row,1)) ;
            y1 = max(1, y(row,1)) ;
            x2 = x(row,1) + w(row,1) ;
            y2 = y(row,1) + h(row,1) ;
        end
        
        im = t_im( y1:y2, x1:x2, : );
        im = imresize(im, face_size);
        imwrite(im, [faces_folder temp_face_id '.jpg']);
    end

end