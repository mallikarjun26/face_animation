function cofw_pre_processing(path)

    %
    load([path '/cofw_data/COFW_test_color.mat']);
    load([path '/cofw_data/COFW_train_color.mat']);
    fid = fopen([path '/cofw_data/image_file_list.txt'], 'w');

    %
    number_of_faces_train = size(IsTr,1);
    number_of_faces_test  = size(IsT,1);
    number_of_faces       = number_of_faces_train + number_of_faces_test;
    facemap = cell(1, number_of_faces);
    ground_truth = cell(1, number_of_faces);
    per_extra = 0.15;
    fids_after = zeros(29,2);

    %
    for i=1:number_of_faces_train
        facemap{i} = [path '/cofw_data/images/' num2str(i) '.jpg'];
        fprintf(fid, [facemap{i} '\n'] );
        im = IsTr{i};
        [im, fids_after] = get_truncated_face(im, phisTr(i,:));
        ground_truth{i} = fids_after;        
        imwrite(im, [path '/cofw_data/images/' num2str(i) '.jpg']);    
    end    

    for i=1:number_of_faces_test
        index = i + number_of_faces_train;
        facemap{index} = [path '/cofw_data/images/' num2str(index) '.jpg'];
        fprintf(fid, [facemap{index} '\n'] );
        im = IsT{i};
        [im, fids_after] = get_truncated_face(im, phisT(i,:));
        ground_truth{index} = fids_after;        
        imwrite(im, [path '/cofw_data/images/' num2str(index) '.jpg']);    
    end    

    fclose(fid);

    %
    save([path '/cofw_data/facemap.mat'], 'facemap');
    save([path '/cofw_data/ground_truth.mat'], 'ground_truth');

end

function [im, fids_after] = get_truncated_face(im, fids)

    fids = uint32([fids(30:58)' fids(1:29)']);
    
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
