function main(path)

    %
    load([path '/common_data/fids_mapping/chehra_deva_rcpr_common_fids.mat']);
    load([path '/chehra_data/intermediate_results/chehra_fids.mat']);
    load([path '/deva_data/intermediate_results/deva_fids.mat']);
    load([path '/rcpr_data/intermediate_results/rcpr_fids.mat']);
    load([path '/Faces5000/intermediate_results/facemap.mat']);

    %
    input_image_num = 3852;
    sim_image_num   = 7;
    
    s_chehra_fid    = chehra_fids{input_image_num};
    s_deva_fid      = deva_fids{input_image_num};
    s_rcpr_fid      = rcpr_fids{input_image_num};
    input_image     = imread(facemap{input_image_num});
    
    sim_fid         = chehra_fids{sim_image_num};
    sim_image       = imread(facemap{sim_image_num});
    
    %
    [shape_chehra_deva, shape_chehra_rcpr, shape_deva_rcpr] = get_shape_similarity(s_chehra_fid, s_deva_fid, s_rcpr_fid, chehra_deva_rcpr_common_fids);
    
    %
    [app_chehra, app_deva, app_rcpr] = get_appearance_similarity(s_chehra_fid, s_deva_fid, s_rcpr_fid, input_image, sim_image, sim_fid, 1, chehra_deva_rcpr_common_fids);


end

function [shape_chehra_deva, shape_chehra_rcpr, shape_deva_rcpr] = get_shape_similarity(s_chehra_fid, s_deva_fid, s_rcpr_fid, chehra_deva_rcpr_common_fids)

    %
    number_of_common_parts = size(chehra_deva_rcpr_common_fids,1);
    t1 = double([ s_chehra_fid(chehra_deva_rcpr_common_fids(:,1),1)' s_chehra_fid(chehra_deva_rcpr_common_fids(:,1),2)' ]);
    x = (s_deva_fid.xy(:,1) + s_deva_fid.xy(:,3) ) / 2 ;
    y = (s_deva_fid.xy(:,2) + s_deva_fid.xy(:,4) ) / 2 ;
    t2 = double([y(chehra_deva_rcpr_common_fids(:,2),1)' x(chehra_deva_rcpr_common_fids(:,2),1)' ]);
    t3 = double([ s_rcpr_fid(chehra_deva_rcpr_common_fids(:,3),1)' s_rcpr_fid(chehra_deva_rcpr_common_fids(:,3),2)' ]);
    
    
    t = [t1 ; t2];
    shape_chehra_deva = pdist(t) / number_of_common_parts;
    
    t = [t1 ; t3];
    shape_chehra_rcpr = pdist(t) / number_of_common_parts;
    
    t = [t2 ; t3];
    shape_deva_rcpr = pdist(t) / number_of_common_parts;
    
end

function [app_chehra, app_deva, app_rcpr] = get_appearance_similarity(s_chehra_fid, s_deva_fid, s_rcpr_fid, input_image, sim_image, sim_fid, sim_model, chehra_deva_rcpr_common_fids)

    %
    [fid_1] = get_fid(s_chehra_fid, 1, chehra_deva_rcpr_common_fids);
    [fid_2] = get_fid(s_deva_fid, 2, chehra_deva_rcpr_common_fids);
    [fid_3] = get_fid(s_rcpr_fid, 3, chehra_deva_rcpr_common_fids);
    [fid_t] = get_fid(sim_fid, sim_model, chehra_deva_rcpr_common_fids);
    
    %
    app_chehra = get_sift_similarity(input_image, fid_1, sim_image, fid_t);
    app_deva = get_sift_similarity(input_image, fid_2, sim_image, fid_t);
    app_rcpr = get_sift_similarity(input_image, fid_3, sim_image, fid_t);
    
    
end

function [fid] = get_fid(fid, fid_mode, chehra_deva_rcpr_common_fids)

    if(fid_mode == 2)
        y = uint32((fid.xy(chehra_deva_rcpr_common_fids(:,3),2) + fid.xy(chehra_deva_rcpr_common_fids(:,3),4)) / 2);
        x = uint32((fid.xy(chehra_deva_rcpr_common_fids(:,3),1) + fid.xy(chehra_deva_rcpr_common_fids(:,3),3)) / 2);
        fid = [y x];
    else
        y = fid(chehra_deva_rcpr_common_fids(:,fid_mode),1);
        x = fid(chehra_deva_rcpr_common_fids(:,fid_mode),2);
        fid = [y x];
    end

end

function sift_similarity = get_sift_similarity(im_1, fid_1, im_2, fid_2)

    %
    im_1 = rgb2gray(im_1);
    im_2 = rgb2gray(im_2);
    number_of_parts = size(fid_1,1);

    %
    sift_similarity = 0;
    for i=1:number_of_parts
        im_part = single(get_im_part(im_1, fid_1(i,:)));
        [~, sift_1] = vl_sift(im_part);
        im_part = single(get_im_part(im_2, fid_2(i,:)));
        [~, sift_2] = vl_sift(im_part);
        if(~isempty(sift_1) && ~isempty(sift_2))
            match_score = sum(vl_ubcmatch(sift_1, sift_2));
        else
            match_score = 0;
        end
        sift_similarity = sift_similarity + match_score;
    end
    sift_similarity = sift_similarity;
    
end

function im_part = get_im_part(im, fid_pt)

    y1 = max(fid_pt(1,1) - 5, 1);
    x1 = max(fid_pt(1,2) - 5, 1);
    y2 = min(fid_pt(1,1) + 5, size(im,1));
    x2 = min(fid_pt(1,2) + 5, size(im,2));
    im_part = im(y1:y2, x1:x2);
    im_part = imresize(im_part, [10 10]);
        
end

