function get_selected_train_faces(path, dataset, shape_app_mode, kmeans_pca_mode, NUMCENTERS)

    %
    run('~/src/vlfeat/vlfeat-0.9.19/toolbox/vl_setup');

    %
    load([path '/' dataset '_data/facemap.mat']);
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);

    %
    % NUMCENTERS = 20;
    if(dataset=='aflw')
        load([path '/' dataset '_data/ground_truth_smith.mat']);
    else
        load([path '/' dataset '_data/ground_truth.mat']);
    end

    if(shape_app_mode == 1)
        [X, mod_to_ori_map] = get_shape_X(ground_truth, dataset);
    elseif(shape_app_mode == 2)
        [X, mod_to_ori_map] = get_appearance_X(ground_truth, dataset, facemap, chehra_deva_intraface_rcpr_common_fids);
    end

    if(kmeans_pca_mode == 1)
        sim_list = get_kmeans_based_list(ground_truth, dataset, NUMCENTERS, X, mod_to_ori_map);
    elseif(kmeans_pca_mode == 2)
        sim_list = get_pca_based_list(ground_truth, dataset, NUMCENTERS, X, mod_to_ori_map);
    end

    %
    if(shape_app_mode == 1)
        shape_app_l = 'shape_en';
    else
        shape_app_l = 'app_en';
    end
     
    if(kmeans_pca_mode == 1)
        save([path '/' dataset '_data/sim_image_list_kmeans_' shape_app_l '.mat'], 'sim_list');
    else
        save([path '/' dataset '_data/sim_image_list_pca_' shape_app_l '.mat'], 'sim_list');
    end
end

function [X, mod_to_ori_map] = get_appearance_X(ground_truth, dataset, facemap, chehra_deva_intraface_rcpr_common_fids)

    %
    if(dataset == 'lfpw')
        number_of_training_samples = 811; 
        number_of_fids = 68;
        col_num = 7;
    elseif(dataset == 'cofw')
        number_of_training_samples = 1345;
        number_of_fids = 29;
        col_num = 8;
    elseif(dataset == 'aflw')
        number_of_training_samples = 18000;
        number_of_fids = 85;
        col_num = 10;
    end

    %
    X = [];
    mod_to_ori_map = [];
    for i=1:number_of_training_samples
        im = imread(facemap{i});
        if(size(im,3)==3)
            im = single(rgb2gray(im));
        else
            im = single(im);
        end
        fids = ground_truth{i};
        
        if(isempty(fids))
            continue;
        end
        mod_to_ori_map = [mod_to_ori_map ; i];
        
        fids = get_fid(fids, col_num, chehra_deva_intraface_rcpr_common_fids);
        num_of_parts = size(chehra_deva_intraface_rcpr_common_fids, 1);

        t_p = [];
        for j=1:num_of_parts
            y = fids(j, 1);
            x = fids(j, 2);
            t_p = [t_p ; get_part_patch(x, y, im)];  
        end
        X = [X t_p];
    end

end

function t_p = get_part_patch(x, y, im)
    
    im_size = size(im);
    x1 = uint32(max(x - (im_size(1,2)*0.015),1)); 
    x2 = uint32(min(x + (im_size(1,2)*0.015), im_size(1,2))); 
    y1 = uint32(max(y - (im_size(1,1)*0.015),1)); 
    y2 = uint32(min(y + (im_size(1,1)*0.015), im_size(1,1))); 
   
    if( (x1>=x2) || (y1>=y2) )
        x1 = im_size(1,2);
        x2 = x1;
        y1 = im_size(1,1);
        y2 = y1;
    end
    im_part = im(y1:y2, x1:x2);
    im_part = imresize(im_part, [10 10]);
    t_p = reshape(im_part, [size(im_part(:), 1), 1]);
end

function sim_list = get_pca_based_list(ground_truth, dataset, NUMCENTERS, X, mod_to_ori_map)
    %
    X = X';
    [C] = pca(X);

    %
    sim_list = get_subset_based_pca(C, X, NUMCENTERS, mod_to_ori_map);    
end

function sim_list = get_subset_based_pca(C, X, NUMCENTERS, mod_to_ori_map)

    sim_list = NaN * ones(NUMCENTERS, 1); 
    num_of_samples = size(X, 1);

    for i=1:NUMCENTERS
        m_dist = realmin;
        a=C(:,i)';
        for j=1:num_of_samples
            b=X(j,:);
            dist_t = dot(a, b) / norm(b);
            if(dist_t > m_dist)
                sim_list(i) = j;
                m_dist = dist_t;
            end
        end
    end

    for i=1:NUMCENTERS
        sim_list(i) = mod_to_ori_map(sim_list(i));
    end

end

function sim_list = get_kmeans_based_list(ground_truth, dataset, NUMCENTERS, X, mod_to_ori_map)
    %
    [C, A] = vl_kmeans(X, NUMCENTERS);

    %
    sim_list = get_subset_based_kmeans(C, A, X, NUMCENTERS, mod_to_ori_map);    
end

function sim_list = get_subset_based_kmeans(C, A, X, NUMCENTERS, mod_to_ori_map)

    sim_list = zeros(NUMCENTERS, 1);
    sample_num = cell(NUMCENTERS,1);
    
    for i=1:NUMCENTERS
        a = find(A==i);
        sample_num{i,1} = a;
    end 

    for i=1:NUMCENTERS
        list = sample_num{i};
        num_samples_each = size(list,2);    
        center_sample = C(:,i);
        min_dist = realmax;
        for j=1:num_samples_each
            sim_list_t = list(j);
            temp = [center_sample' ; X(:,sim_list_t)' ];     
            dist_t = pdist(temp);

            if(dist_t < min_dist)
                min_dist = dist_t;
                sim_list(i) = sim_list_t;
            end 
        end
    end

    for i=1:NUMCENTERS
        sim_list(i) = mod_to_ori_map(sim_list(i));
    end
    
end


function [X, mod_to_ori_map] = get_shape_X(ground_truth, dataset)

    %
    if(dataset == 'lfpw')
        number_of_training_samples = 811; 
        number_of_fids = 68;
    elseif(dataset == 'cofw')
        number_of_training_samples = 1345;
        number_of_fids = 29;
    elseif(dataset == 'aflw')
        number_of_training_samples = 18000;
        number_of_fids = 85;
    end

    %X = zeros(number_of_fids*2, number_of_training_samples);
    X = [];
    mod_to_ori_map = [];
    for i=1:number_of_training_samples;
        fid = ground_truth{i};
        if(isempty(fid))
            continue;
        end
        %X(:,i) = [fid(:,1); fid(:,2)];
        mod_to_ori_map = [mod_to_ori_map ; i];
        X = [X [fid(:,1); fid(:,2)]];
    end

    X = double(X);
end
function [fid_o] = get_fid(fid, fid_mode, chehra_deva_intraface_rcpr_common_fids)

    if(fid_mode == 2)
        
        fid_mode_u = 0;
        if( (fid.c>3) && (fid.c<11) )
            fid_mode_u = 2;
        elseif(fid.c>10)
            fid_mode_u = 6;
        else
            fid_mode_u = 5;
        end
        
        
        y = NaN * ones(size(chehra_deva_intraface_rcpr_common_fids,1), 1);
        x = y;
        for i=1:size(chehra_deva_intraface_rcpr_common_fids,1)
            index = chehra_deva_intraface_rcpr_common_fids(i, fid_mode_u);
            if(~isnan(index))
                y(i,1) = uint32((fid.xy(index,2) + fid.xy(index,4)) / 2);
                x(i,1) = uint32((fid.xy(index,1) + fid.xy(index,3)) / 2);
            end
        end
        
        fid_o = ([y x]);
    else
        number_of_parts = size(chehra_deva_intraface_rcpr_common_fids, 1);
        
        y = NaN * ones(size(chehra_deva_intraface_rcpr_common_fids,1), 1);
        x = y;
        for i=1:number_of_parts
            index = chehra_deva_intraface_rcpr_common_fids(i,fid_mode);
            if(~isnan(index))
                y(i,1) = fid(index, 1);
                x(i,1) = fid(index, 2);
            end
        end
        fid_o = ([y x]);
        
%         y = fid(chehra_deva_intraface_rcpr_common_fids(:,fid_mode),1);
%         x = fid(chehra_deva_intraface_rcpr_common_fids(:,fid_mode),2);
%         fid_o = ([y x]);
    end
end
