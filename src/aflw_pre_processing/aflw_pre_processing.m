function aflw_pre_processing(path)

    %
    addpath(genpath('~/src/mksqlite'));

    %

    dbid = mksqlite(2, 'open', [path '/aflw_data/aflw/aflw-db/data/aflw.sqlite']);
    faces = mksqlite(dbid, 'select * from faces');
    feature_coords = mksqlite(dbid, 'select * from featurecoords');
    jpg_list = dir([path '/aflw_data/aflw/images/*.jpg']);
    png_list = dir([path '/aflw_data/aflw/images/*.png']);
    number_of_faces = size(jpg_list, 1) + size(png_list, 1);
    number_of_faces_temp = size(faces,1);
    %facemap = cell(1, number_of_faces);
    facemap = cell(1, 4000);
    ground_truth = cell(number_of_faces, 1);
    image_file_list = fopen([path '/aflw_data/image_file_list.txt'], 'w');
    
    %
    j=0;
    for i=1:number_of_faces_temp
        
        if(mod(i,20)==0)
            disp([num2str(i) '/' num2str(number_of_faces_temp) ' done']);
        end
        if(j==4000)
            break;
        end
      
        face_path = [path '/aflw_data/aflw/images/' faces(i).file_id];
        if(exist(face_path))
            j = j + 1;
            im = imread(face_path);
            face_id = faces(j).face_id;
            fids_before = mksqlite(dbid, ['select * from featurecoords where face_id = ' num2str(face_id)]);
            [im, fids_after] = get_truncated_face(im, faces(i).file_id, path, fids_before);
            face_path_temp = [path '/aflw_data/images/' num2str(j) '.jpg'];
            facemap{j} = face_path_temp;
            fprintf(image_file_list, [facemap{j} '\n']);
            imwrite(im, face_path_temp);
            ground_truth{j} = fids_after;
        end
      
    end
    fclose(image_file_list);
    
    %
    save([path '/aflw_data/facemap.mat'], 'facemap');
    save([path '/aflw_data/ground_truth.mat'], 'ground_truth');

end

function [im, fids_after] = get_truncated_face(im, file_id, path, fids_before)

    %
    per_extra = 0.15;
    number_of_entries = size(fids_before,1);
    fids_after = NaN * ones(21,2);
    
    %
    for i=1:number_of_entries
        feature_id = fids_before(i).feature_id;
        y = fids_before(i).y;    
        x = fids_before(i).x;
        fids_after(feature_id, :) = [y x];
    end
     
    %

    im_size_x = size(im,2);
    im_size_y = size(im,1);

    width = max(fids_after(:,2)) - min(fids_after(:,2));
    height = max(fids_after(:,1)) - min(fids_after(:,1));

	x1 = max( (min(fids_after(:,2)) - (per_extra * width))  , 1);
    y1 = max( (min(fids_after(:,1)) - (per_extra * height))  , 1);
    x2 = min( (max(fids_after(:,2)) + (per_extra * width))  , im_size_x);
    y2 = min( (max(fids_after(:,1)) + (per_extra * height))  , im_size_y);
    
    im = im(uint32(y1:y2), uint32(x1:x2), :);

    %fids_after = get_collab_fids(x1, y1, x2, y2, file_id, path);

    if(~isempty(fids_after))
        fids_after = [fids_after(:,1)-y1 fids_after(:,2)-x1];
        fids_after(:,1) = fids_after(:,1) * (300 / size(im,1));
        fids_after(:,2) = fids_after(:,2) * (300 / size(im,2));
    end

    % fids_after = [fids_after(:,1)-y1 fids_after(:,2)-x1];

    % fids_after(:,1) = fids_after(:,1) * (300 / size(im,1));
    % fids_after(:,2) = fids_after(:,2) * (300 / size(im,2));
    im = imresize(im, [300 300]);

end

function fids_collab_after = get_collab_fids(x1, y1, x2, y2, file_id, path)

    ind = find(file_id(:)=='.');
    file_id = file_id(1:ind-1);
    fids_file_list = dir([path '/aflw_data/aflw_supp_2014-09-11/landmarks/' file_id '*.txt' ]);
    fids_collab_after = [];

    if(isempty(fids_file_list) == 1)
        fids_collab_after = [];
        return;
    end

    for i=1:size(fids_file_list,1)
        fids_file_id = [path '/aflw_data/aflw_supp_2014-09-11/landmarks/' fids_file_list(i).name ];
        file_ptr = fopen(fids_file_id);
        temp_fids = textscan(file_ptr, '%f %f', 'HeaderLines', 1);
        fclose(file_ptr);
        temp_fids = [temp_fids{2} temp_fids{1}];
        x_m = mean(temp_fids(:,2));
        y_m = mean(temp_fids(:,1));
        if( (x_m>x1) && (x_m<x2) && (y_m>y1) && (y_m<y2) )
            fids_collab_after = temp_fids;
            break;
        end
    end

end
