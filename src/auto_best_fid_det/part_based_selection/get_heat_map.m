function heat_map = get_heat_map(c_f, d_f, i_f, r_f, im, feat_rf)

    im_y = size(im, 1); 
    im_x = size(im, 2); 
    heat_map = Inf * ones(im_y, im_x);

    [y1, x1, y2, x2] = get_bb(c_f, d_f, i_f, r_f, im);

    for i = y1:y2
        for j = x1:x2
            feat_pt = get_app_feature(j, i, im); 
            dis_score = 0;
            for k=1:4
                dis_score = dis_score + pdist([feat_pt; feat_rf{k}]);
            end
            heat_map(i,j) = dis_score / 4; 
        end
    end

    heat_map = normalize_heat_map(heat_map);
    
end

function out_heat_map = normalize_heat_map(heat_map)

    map_size = size(heat_map);
    out_heat_map = zeros(map_size);
    
    non_inf_ind = uint32(find(~isinf(heat_map)));
    
    max_dist = max(heat_map(non_inf_ind));
    out_heat_map(non_inf_ind) = max_dist - heat_map(non_inf_ind);
    sum_of_dist = sum(out_heat_map(:));
    out_heat_map = out_heat_map / sum_of_dist;

end

function [y1, x1, y2, x2] = get_bb(c_f, d_f, i_f, r_f, im)
    y1 = uint32(min([c_f(1,1) d_f(1,1) i_f(1,1) r_f(1,1)]));
    x1 = uint32(min([c_f(1,2) d_f(1,2) i_f(1,2) r_f(1,2)]));
    y2 = uint32(max([c_f(1,1) d_f(1,1) i_f(1,1) r_f(1,1)]));
    x2 = uint32(max([c_f(1,2) d_f(1,2) i_f(1,2) r_f(1,2)]));
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
