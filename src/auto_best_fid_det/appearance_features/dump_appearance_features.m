function dump_appearance_features(path)

    %
    clc;

    %
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
    load([path '/chehra_data/intermediate_results/chehra_fids.mat']);
    load([path '/deva_data/intermediate_results/deva_fids.mat']);
    load([path '/intraface_data/intermediate_results/intraface_fids.mat']);
    load([path '/rcpr_data/intermediate_results/rcpr_fids.mat']);
    load([path '/Faces5000/intermediate_results/facemap.mat']);

    %
    number_of_faces = size(facemap,2);
    chehra_app_features = cell(number_of_faces,1);
    deva_app_features = cell(number_of_faces,1);
    intraface_app_features = cell(number_of_faces,1);
    rcpr_app_features = cell(number_of_faces,1);
    
    %
    for i=1:number_of_faces
       
        im = single(rgb2gray(imread(facemap{i})));
        
        [fid_c] = get_fid(chehra_fids{i}, 1, chehra_deva_intraface_rcpr_common_fids);
        [fid_d] = get_fid(deva_fids{i}, 2, chehra_deva_intraface_rcpr_common_fids);
        [fid_i] = get_fid(intraface_fids{i}, 3, chehra_deva_intraface_rcpr_common_fids);
        [fid_r] = get_fid(rcpr_fids{i}, 4, chehra_deva_intraface_rcpr_common_fids);
        
        chehra_app_features{i} = get_c_i_r_app_features(im, fid_c, chehra_deva_intraface_rcpr_common_fids, 1);
        deva_app_features{i} = get_deva_app_features(im, fid_d, chehra_deva_intraface_rcpr_common_fids, 2);
        intraface_app_features{i} = get_c_i_r_app_features(im, fid_i, chehra_deva_intraface_rcpr_common_fids, 3);
        rcpr_app_features{i} = get_c_i_r_app_features(im, fid_r, chehra_deva_intraface_rcpr_common_fids, 4);
        
    end
    

end

function app_feature = get_c_i_r_app_features(im, fids, chehra_deva_intraface_rcpr_common_fids, c_i_r)
    
    %
    if(isempty(fids))
        app_feature = [];
        return;        
    end
    %
    number_of_parts = size(chehra_deva_intraface_rcpr_common_fids,1);
    sift_scale_1_feat = zeros(number_of_parts, 128);
    sift_scale_2_feat = zeros(number_of_parts, 128);
    hog_feat = zeros(number_of_parts, (3*3*31));
    
    %
    im_size = size(im);
    for i=1:number_of_parts
        
        index = chehra_deva_intraface_rcpr_common_fids(i,c_i_r);
        x = fids(i,2);
        y = fids(i,1);
        
        fc_1 = double([x; y; 5; 0]);
        [~, sift_scale_1_feat(i,:)] = vl_sift(im,'frames',fc_1) ;
        
        fc_2 = double([x; y; 8; 0]);
        [~, sift_scale_2_feat(i,:)] = vl_sift(im,'frames',fc_2) ;

        x1 = uint32(max(x - (im_size(1,2)*0.015),1)); 
        x2 = uint32(min(x + (im_size(1,2)*0.015), im_size(1,2))); 
        y1 = uint32(max(y - (im_size(1,1)*0.015),1)); 
        y2 = uint32(min(y + (im_size(1,1)*0.015), im_size(1,1))); 
        im_part = im_1(y1:y2, x1:x2);
        im_part = imresize(im_part, [10 10]);
        hog_t = vl_hog(im_part, 3);
        hog_feat(i,:) = reshape(hog_t, [1,size(hog_1(:))]);
    end

end

function [fid] = get_fid(fid, fid_mode, chehra_deva_intraface_rcpr_common_fids)

    if(fid_mode == 2)
        y = uint32((fid.xy(chehra_deva_intraface_rcpr_common_fids(:,3),2) + fid.xy(chehra_deva_intraface_rcpr_common_fids(:,3),4)) / 2);
        x = uint32((fid.xy(chehra_deva_intraface_rcpr_common_fids(:,3),1) + fid.xy(chehra_deva_intraface_rcpr_common_fids(:,3),3)) / 2);
        fid = [y x];
    else
        y = fid(chehra_deva_intraface_rcpr_common_fids(:,fid_mode),1);
        x = fid(chehra_deva_intraface_rcpr_common_fids(:,fid_mode),2);
        fid = [y x];
    end

end