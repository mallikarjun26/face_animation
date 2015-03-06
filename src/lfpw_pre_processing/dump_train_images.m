function dump_train_images(path)

    %
    load([path '/lfpw_data/facemap.mat']);
    load([path '/belhumeur_data/intermediate_results/global_fiducials.mat']);
    ori_file = dir([path '/belhumeur_data/lfpw/trainset/*.png']);
    
    %
    number_of_faces = size(facemap,2);

    %
    for i=1:number_of_faces
        
        im = imread([path '/belhumeur_data/lfpw/trainset/' ori_file(i).name]);
        im = get_truncated_face(im, global_fiducials{i});
        imwrite(im, facemap{i});
    end
    
end


function im = get_truncated_face(im, fids)
    
    im_size_x = size(im,2);
    im_size_y = size(im,1);

    width = max(fids(:,2)) - min(fids(:,2));
    height = max(fids(:,1)) - min(fids(:,1));

	x1 = max( min(fids(:,2)) - (0.25 * width)  , 1);
    y1 = max( min(fids(:,1)) - (0.25 * height)  , 1);
    x2 = min( max(fids(:,2)) + (0.25 * width)  , im_size_x);
    y2 = min( max(fids(:,1)) + (0.25 * height)  , im_size_y);
    
    im = im(y1:y2, x1:x2, :);
end
