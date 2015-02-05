function scale_faces(input_path)

    % load mat files
    load([input_path '/intermediate_results/facemap.mat']);
    
    %
    face_size = [250 250];
    
    %%
    number_of_nodes = size(facemap, 2);
    
    for i = 1 : number_of_nodes
       file_name = facemap{1,i}; 
       im = imread(file_name);
       im = imresize(im, face_size);
       delete(file_name);
       imwrite(im, file_name);
    end

end