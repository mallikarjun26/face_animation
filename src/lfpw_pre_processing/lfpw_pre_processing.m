function lfpw_pre_processing(path)


    train_files = dir([path '/belhumeur_data/lfpw/trainset/*.png']);
    test_files  = dir([path '/belhumeur_data/lfpw/testset/*.png']);

    image_file_list = fopen([path '/lfpw_data/image_file_list.txt'], 'w');
    
    %
    number_of_train_faces  = size(train_files,1);
    number_of_test_faces   = size(test_files,1);
    number_of_faces        = number_of_train_faces + number_of_test_faces;
    ground_truth           = cell(number_of_faces,  1);
    facemap                = cell(1, number_of_faces);

    %
    for i=1:number_of_train_faces
        facemap{i} = [path '/lfpw_data/images/' num2str(i) '.png'];
        ori_face_path = [path '/belhumeur_data/lfpw/trainset/' train_files(i).name]; 
        im = imread(ori_face_path);
        fids_before = get_fids(ori_face_path);
        [im, fids_after]= get_truncated_face(im, fids_before);
        imwrite(im, facemap{i});
        ground_truth{i} = fids_after;
        fprintf(image_file_list, [facemap{i} '\n']);
    end

    %
    for i=1:number_of_test_faces
        index = i + number_of_train_faces;
        facemap{index} = [path '/lfpw_data/images/' num2str(index) '.png'];
        ori_face_path = [path '/belhumeur_data/lfpw/testset/' test_files(i).name]; 
        im = imread(ori_face_path);
        fids_before = get_fids(ori_face_path);
        [im, fids_after]= get_truncated_face(im, fids_before);
        imwrite(im, facemap{index});
        ground_truth{index} = fids_after;
        fprintf(image_file_list, [facemap{index} '\n']);
    end
    
    %
    save([path '/lfpw_data/facemap.mat'], 'facemap');
    save([path '/lfpw_data/ground_truth.mat'], 'ground_truth');
    fclose(image_file_list);
end

function [fids_after] = get_fids(path)

    dot_index = find(path=='.');
    fids_file = [path(1:dot_index) 'pts'];
    fids_ptr = fopen(fids_file);
    fids_content = textscan(fids_ptr, '%f %f', 'HeaderLines', 3);
    fids_after = uint32([fids_content{2} fids_content{1}]);

end

function [im, fids_after] = get_truncated_face(im, fids)
    
    per_extra = 0.15;

    im_size_x = size(im,2);
    im_size_y = size(im,1);

    width = max(fids(:,2)) - min(fids(:,2));
    height = max(fids(:,1)) - min(fids(:,1));

	x1 = max( uint32(min(fids(:,2)) - (per_extra * width))  , 1);
    y1 = max( uint32(min(fids(:,1)) - (per_extra * height))  , 1);
    x2 = min( uint32(max(fids(:,2)) + (per_extra * width))  , im_size_x);
    y2 = min( uint32(max(fids(:,1)) + (per_extra * height))  , im_size_y);
    
    im = im(y1:y2, x1:x2, :);
    fids_after = [fids(:,1)-y1 fids(:,2)-x1];
end
