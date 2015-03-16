function dump_lfpw_image_file_list(path)

    %
    fid = fopen([path '/lfpw_data/image_file_list.txt'], 'w');
    load('~/data/face_animation/lfpw_data/facemap.mat');
         
    %
    num_of_faces = size(facemap, 2);
    
    %
    for i=1:num_of_faces
        fprintf(fid, [facemap{i} '\n'] );
    end
    
end
