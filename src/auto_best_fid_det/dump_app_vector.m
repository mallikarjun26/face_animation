function dump_app_vector(path, dataset)
    
    %
    clc;
    run('/home/mallikarjun/src/vlfeat/vlfeat-0.9.19/toolbox/vl_setup')

    %
    chehra_fids = [];
    deva_fids = [];
    rcpr_fids = [];
    intraface_fids = [];
    ground_truth = [];
    chehra_deva_intraface_rcpr_common_fids = [];
    
    %
    if(dataset == 'jack')
        load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
        load([path '/chehra_data/intermediate_results/chehra_fids.mat']);
        load([path '/deva_data/intermediate_results/deva_fids.mat']);
        load([path '/intraface_data/intermediate_results/intraface_fids.mat']);
        load([path '/rcpr_data/intermediate_results/rcpr_fids.mat']);
        load([path '/Faces5000/intermediate_results/facemap.mat']);
    else
        load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
        load([path '/' dataset '_data/chehra_fids.mat']);
        load([path '/' dataset '_data/deva_fids.mat']);
        load([path '/' dataset '_data/intraface_fids.mat']);
        load([path '/' dataset '_data/rcpr_fids.mat']);
        load([path '/' dataset '_data/ground_truth.mat']);
        load([path '/' dataset '_data/facemap.mat']);
    end

    %
    number_of_faces = size(facemap,2);
    number_of_parts = size(chehra_deva_intraface_rcpr_common_fids, 1);
    chehra_app_vector = cell(number_of_faces, 1);
    deva_app_vector = cell(number_of_faces, 1);
    intraface_app_vector = cell(number_of_faces, 1);
    rcpr_app_vector = cell(number_of_faces, 1);
    ground_truth_app_vector = cell(number_of_faces, 1);

    %
    for i=1:number_of_faces
        if(mod(i,1) == 0)
            disp([ num2str(i) '/' num2str(number_of_faces) 'done' ]);
        end
           
        im = imread(facemap{i});
        if(size(im,3)==3)
            im = single(rgb2gray(im));
        else
            im = single(im);
        end
        
        s_chehra_fid    = chehra_fids{i};
        s_deva_fid      = deva_fids{i};
        s_rcpr_fid      = rcpr_fids{i};
        s_intraface_fid      = intraface_fids{i};
        s_ground_truth_fid   = ground_truth{i};
         
        if(isempty(s_deva_fid))
            s_deva_fid.xy = NaN * ones(68,4);
            s_deva_fid.c = 7;
        end
        if(isempty(s_intraface_fid))
            s_intraface_fid = NaN * ones(49,2);
        end
        if(isempty(s_rcpr_fid))
            s_rcpr_fid = NaN * ones(29,2);
        end
        if(isempty(s_chehra_fid))
            s_chehra_fid = NaN * ones(49,2);
        end

        [fid_1] = get_fid(s_chehra_fid, 1, chehra_deva_intraface_rcpr_common_fids);
        [fid_2] = get_fid(s_deva_fid, 2, chehra_deva_intraface_rcpr_common_fids);
        [fid_3] = get_fid(s_intraface_fid, 3, chehra_deva_intraface_rcpr_common_fids);
        [fid_4] = get_fid(s_rcpr_fid, 4, chehra_deva_intraface_rcpr_common_fids);
        if(dataset == 'lfpw')
            [fid_5] = get_fid(s_ground_truth_fid, 7, chehra_deva_intraface_rcpr_common_fids);
        elseif(dataset == 'cofw')
            [fid_5] = get_fid(s_ground_truth_fid, 8, chehra_deva_intraface_rcpr_common_fids);
        elseif(dataset == 'aflw')
            [fid_5] = get_fid(s_ground_truth_fid, 9, chehra_deva_intraface_rcpr_common_fids);
        end
    
        chehra_part_app_vector = cell(number_of_parts,1);
        deva_part_app_vector = cell(number_of_parts,1);
        intraface_part_app_vector = cell(number_of_parts,1);
        rcpr_part_app_vector = cell(number_of_parts,1);
        ground_truth_part_app_vector = cell(number_of_parts,1);
        
        fea_vec_size = 535;
        for j=1:number_of_parts
            y = fid_1(j,1); 
            x = fid_1(j,2); 
            
            if(isnan(y) || isnan(x))
                chehra_part_app_vector{j} = NaN * ones(1, fea_vec_size);
            else
                chehra_part_app_vector{j} = get_app_feature(x, y, im);
            end

            y = fid_2(j,1); 
            x = fid_2(j,2); 
            if(isnan(y) || isnan(x))
                deva_part_app_vector{j} = NaN * ones(1, fea_vec_size);
            else
                deva_part_app_vector{j} = get_app_feature(x, y, im);
            end

            y = fid_3(j,1); 
            x = fid_3(j,2); 
            if(isnan(y) || isnan(x))
                intraface_part_app_vector{j} = NaN * ones(1, fea_vec_size);
            else
                intraface_part_app_vector{j} = get_app_feature(x, y, im);
            end

            y = fid_4(j,1); 
            x = fid_4(j,2); 
            if(isnan(y) || isnan(x))
                rcpr_part_app_vector{j} = NaN * ones(1, fea_vec_size);
            else
                rcpr_part_app_vector{j} = get_app_feature(x, y, im);
            end

            y = fid_5(j,1); 
            x = fid_5(j,2); 
            if(isnan(y) || isnan(x))
                ground_truth_part_app_vector{j} = NaN * ones(1, fea_vec_size);
            else
                ground_truth_part_app_vector{j} = get_app_feature(x, y, im);
            end
        end

        chehra_app_vector{i} = chehra_part_app_vector;
        deva_app_vector{i} = deva_part_app_vector;
        intraface_app_vector{i} = intraface_part_app_vector;
        rcpr_app_vector{i} = rcpr_part_app_vector;
        ground_truth_app_vector{i} = ground_truth_part_app_vector;
    end

    %
    save([path '/' dataset '_data/app_based_results/chehra_app_vector.mat'], 'chehra_app_vector');
    save([path '/' dataset '_data/app_based_results/deva_app_vector.mat'], 'deva_app_vector');
    save([path '/' dataset '_data/app_based_results/intraface_app_vector.mat'], 'intraface_app_vector');
    save([path '/' dataset '_data/app_based_results/rcpr_app_vector.mat'], 'rcpr_app_vector');
    save([path '/' dataset '_data/app_based_results/ground_truth_app_vector.mat'], 'ground_truth_app_vector');

end

function part_app_feat = get_app_feature(x, y, im)

    hog_feat = get_hog_feature(x, y, im);
    
    sift_feat = get_sift_feature(x, y, im);
    
    part_app_feat = [hog_feat single(sift_feat)];
end

function hog_feat = get_hog_feature(x, y, im)
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
        
    hog_feat = vl_hog(im_part, 3);
    hog_feat = reshape(hog_feat, [1,size(hog_feat(:))]);
end

function sift_feat = get_sift_feature(x, y, im)
    scales = [5 8];
    sift_feat = [];
    for j=1:2
        fc = double([x; y; scales(j); 0]);
        [~, sift_feat_t] = vl_sift(im,'frames',fc) ;
        sift_feat = [sift_feat sift_feat_t'];
    end
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
