function dump_images_facemap_bbs(path)

    %
    load([path '/cofw_data/COFW_test_color.mat']);
    fid = fopen([path '/cofw_data/image_file_list.txt'], 'w');

    %
    number_of_faces = size(IsT,1);
    facemap = cell(1, number_of_faces);
    ground_truth = cell(1, number_of_faces);
    per_extra = 0.15;
    fids_after = zeros(29,2);

    %
    for i=1:number_of_faces
        facemap{i} = [path '/cofw_data/images/' num2str(i) '.jpg'];
        fprintf(fid, [facemap{i} '\n'] );
        im = IsT{i};
        im_y = size(im,1);
        im_x = size(im,2);
        width = bboxesT(i,3);
        height = bboxesT(i,4);

        x1 = uint16( max( bboxesT(i,1)-per_extra*width , 1) ) ;
        y1 = uint16( max( bboxesT(i,2)-per_extra*height, 1) ) ;
        x2 = uint16( min( bboxesT(i,1) + bboxesT(i,3) + (per_extra*width) ,  im_x ) );
        y2 = uint16( min( bboxesT(i,2) + bboxesT(i,4) + (per_extra*height),  im_y ) );
        im = im(y1:y2, x1:x2, :);

        % ToDo. Ground truth fid locations after cropping update and save
        fids_after(:,2) = uint16(phisT(i, 1:29))  - x1;
        fids_after(:,1) = uint16(phisT(i, 30:58)) - y1;
        ground_truth{i} = fids_after;        
        
        imwrite(im, [path '/cofw_data/images/' num2str(i) '.jpg']);    
    end    
    fclose(fid);

    %
    save([path '/cofw_data/facemap.mat'], 'facemap');
    save([path '/cofw_data/ground_truth.mat'], 'ground_truth');
    dlmwrite([path '/cofw_data/bounding_boxes/bounding_boxes.txt'], bboxesT, ' ');    

end
