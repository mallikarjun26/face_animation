function [fail_rate, mean_err, mean_err_parts] = get_failure_rate_and_mean_errors(path, dataset, err_margin)

    %
    load([path '/' dataset '_data/chehra_fids.mat']);
    load([path '/' dataset '_data/deva_fids.mat']);
    load([path '/' dataset '_data/intraface_fids.mat']);
    load([path '/' dataset '_data/rcpr_fids.mat']);
    load([path '/' dataset '_data/ground_truth.mat']);
    load([path '/' dataset '_data/app_based_results/selected_models.mat']);
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
    load([path '/' dataset '_data/facemap.mat']);

    %
    if(dataset == 'lfpw')
        test_list = [812:1035]';
        gt_col    = 7;
        % test_list = [812:1035]';
        % gt_col    = 7;
    elseif(dataset == 'cofw')
        test_list = [1346:1852]';
        gt_col    = 8;
    elseif(dataset == 'aflw')
        test_list = [1:2500]';
        gt_col    = 9;
    end

    %
    number_of_test_samples = size(test_list, 1);
    c_err = cell(number_of_test_samples, 1);
    d_err = cell(number_of_test_samples, 1);
    i_err = cell(number_of_test_samples, 1);
    r_err = cell(number_of_test_samples, 1);
    o_err = cell(number_of_test_samples, 1);
    
    %
    for i=1:number_of_test_samples
        index = test_list(i);
    
        gt_fid = ground_truth{index};
        c_fid  = chehra_fids{index};
        d_fid  = deva_fids{index};
        i_fid  = intraface_fids{index};
        r_fid  = rcpr_fids{index};
        
        if(isempty(d_fid))
            d_fid.xy = NaN * ones(68,4);
            d_fid.c = 7;
        end
        if(isempty(i_fid))
            i_fid = NaN * ones(49,2);
        end
        if(isempty(r_fid))
            r_fid= NaN * ones(29,2);
        end
        if(isempty(c_fid))
            c_fid = NaN * ones(49,2);
        end

        int_oc_dist = get_int_oc_dist(gt_fid, gt_col, chehra_deva_intraface_rcpr_common_fids, facemap{index}); 

        [c_err{i}, d_err{i}, i_err{i}, r_err{i}, o_err{i}] = get_error(gt_fid, c_fid, d_fid, i_fid, r_fid, selected_models(index), int_oc_dist, chehra_deva_intraface_rcpr_common_fids, gt_col);

    end

    [c_fail_rate, d_fail_rate, i_fail_rate, r_fail_rate, o_fail_rate] = get_failure_rate(c_err, d_err, i_err, r_err, o_err, err_margin); 
    [c_mean_err, d_mean_err, i_mean_err, r_mean_err, o_mean_err] = get_mean_error(c_err, d_err, i_err, r_err, o_err, err_margin); 
    
    fail_rate       = [c_fail_rate, d_fail_rate, i_fail_rate, r_fail_rate, o_fail_rate];
    mean_err_parts  = [c_mean_err d_mean_err i_mean_err r_mean_err o_mean_err];
    mean_err        = [mean(c_mean_err(find(~isnan(c_mean_err)))) mean(d_mean_err(find(~isnan(d_mean_err)))) mean(i_mean_err(find(~isnan(i_mean_err)))) mean(r_mean_err(find(~isnan(r_mean_err)))) mean(o_mean_err(find(~isnan(o_mean_err))))];

end

function [c_mean_err, d_mean_err, i_mean_err, r_mean_err, o_mean_err] = get_mean_error(c_err, d_err, i_err, r_err, o_err, err_margin)

    num_of_samples = size(c_err, 1);
    num_of_parts   = size(c_err{1}, 1);
    c_mean_err = zeros(num_of_parts,2);
    d_mean_err = zeros(num_of_parts,2);
    i_mean_err = zeros(num_of_parts,2);
    r_mean_err = zeros(num_of_parts,2);
    o_mean_err = zeros(num_of_parts,2);

    for i=1:num_of_samples
        c_err_t = c_err{i}; 
        d_err_t = d_err{i}; 
        i_err_t = i_err{i}; 
        r_err_t = r_err{i}; 
        o_err_t = o_err{i}; 
        for j=1:num_of_parts
            if(~isnan(c_err_t(j)))
                c_mean_err(j,1) = c_mean_err(j,1) + c_err_t(j);
                c_mean_err(j,2) = c_mean_err(j,2) + 1;
            end
            if(~isnan(d_err_t(j)))
                d_mean_err(j,1) = d_mean_err(j,1) + d_err_t(j);
                d_mean_err(j,2) = d_mean_err(j,2) + 1;
            end
            if(~isnan(i_err_t(j)))
                i_mean_err(j,1) = i_mean_err(j,1) + i_err_t(j);
                i_mean_err(j,2) = i_mean_err(j,2) + 1;
            end
            if(~isnan(r_err_t(j)))
                r_mean_err(j,1) = r_mean_err(j,1) + r_err_t(j);
                r_mean_err(j,2) = r_mean_err(j,2) + 1;
            end
            if(~isnan(o_err_t(j)))
                o_mean_err(j,1) = o_mean_err(j,1) + o_err_t(j);
                o_mean_err(j,2) = o_mean_err(j,2) + 1;
            end
        end         
    end

    c_mean_err = c_mean_err(:,1) ./ c_mean_err(:,2);
    d_mean_err = d_mean_err(:,1) ./ d_mean_err(:,2);
    i_mean_err = i_mean_err(:,1) ./ i_mean_err(:,2);
    r_mean_err = r_mean_err(:,1) ./ r_mean_err(:,2);
    o_mean_err = o_mean_err(:,1) ./ o_mean_err(:,2);

end


function [c_fail_rate, d_fail_rate, i_fail_rate, r_fail_rate, o_fail_rate] = get_failure_rate(c_err, d_err, i_err, r_err, o_err, err_margin)
    
    num_of_samples = size(c_err, 1); 
    c_fail_rate = 0;
    d_fail_rate = 0;
    i_fail_rate = 0;
    r_fail_rate = 0;
    o_fail_rate = 0;

    for i=1:num_of_samples

        c_fail_rate = c_fail_rate + did_fail(c_err{i}, err_margin);    
        d_fail_rate = d_fail_rate + did_fail(d_err{i}, err_margin);    
        i_fail_rate = i_fail_rate + did_fail(i_err{i}, err_margin);    
        r_fail_rate = r_fail_rate + did_fail(r_err{i}, err_margin);    
        o_fail_rate = o_fail_rate + did_fail(o_err{i}, err_margin);    
    end

    c_fail_rate = c_fail_rate / num_of_samples;
    d_fail_rate = d_fail_rate / num_of_samples;
    i_fail_rate = i_fail_rate / num_of_samples;
    r_fail_rate = r_fail_rate / num_of_samples;
    o_fail_rate = o_fail_rate / num_of_samples;
    
end

function fail = did_fail(err_s, err_margin)

    num_of_parts  = size(err_s);
    non_nan_index = find(~isnan(err_s));
    num_of_non_nan= size(non_nan_index, 1);
    num_of_nan    = num_of_parts - num_of_non_nan; 

    if(num_of_nan == num_of_parts)
        fail = 1;
        return;
    end

    mean_err = sum(err_s(non_nan_index)) / num_of_non_nan; 
    if(mean_err>err_margin)
        fail = 1;
    else
        fail = 0;
    end
end


function [c_err, d_err, i_err, r_err, o_err] = get_error(gt_fid, c_fid, d_fid, i_fid, r_fid, sel_model, int_oc_dist, chehra_deva_intraface_rcpr_common_fids, gt_col)

    num_of_parts = size(chehra_deva_intraface_rcpr_common_fids, 1);
    c_err = NaN * ones(num_of_parts, 1);    
    d_err = NaN * ones(num_of_parts, 1);    
    i_err = NaN * ones(num_of_parts, 1);    
    r_err = NaN * ones(num_of_parts, 1);    
    
    d_fid_o = d_fid;
    
    gt_fid = get_fid(gt_fid, gt_col, chehra_deva_intraface_rcpr_common_fids);
    c_fid  = get_fid(c_fid, 1, chehra_deva_intraface_rcpr_common_fids);
    d_fid  = get_fid(d_fid, 2, chehra_deva_intraface_rcpr_common_fids);
    i_fid  = get_fid(i_fid, 3, chehra_deva_intraface_rcpr_common_fids);
    r_fid  = get_fid(r_fid, 4, chehra_deva_intraface_rcpr_common_fids);

    for i=1:num_of_parts
        
        if(isnan(chehra_deva_intraface_rcpr_common_fids(i,gt_col)))
            c_err(i) = NaN; 
            d_err(i) = NaN; 
            i_err(i) = NaN; 
            r_err(i) = NaN;     
            continue;
        end
        
        c_err(i) = pdist([c_fid(i,:); gt_fid(i,:)]) / int_oc_dist; 
        d_err(i) = pdist([d_fid(i,:); gt_fid(i,:)]) / int_oc_dist; 
        i_err(i) = pdist([i_fid(i,:); gt_fid(i,:)]) / int_oc_dist; 
        r_err(i) = pdist([r_fid(i,:); gt_fid(i,:)]) / int_oc_dist; 
        if(isnan(c_fid(i,1)))
            c_err(i) = 0.1;
        end
        if(isnan(d_fid(i,1)) && (d_fid_o.c==7))
            d_err(i) = 0.1;
        end
        if(isnan(i_fid(i,1)))
            i_err(i) = 0.1;
        end
        if(isnan(r_fid(i,1)))
            r_err(i) = 0.1;
        end
    end

    switch sel_model
        
        case 1
            o_err = c_err;
        case 2
            o_err = d_err;
        case 3
            o_err = i_err;
        case 4
            o_err = r_err;
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

    end

end


function int_oc_dist =  get_int_oc_dist(gt_fid, gt_col, chehra_deva_intraface_rcpr_common_fids, face_path)

    ind_1 = chehra_deva_intraface_rcpr_common_fids(11, gt_col);
    ind_2 = chehra_deva_intraface_rcpr_common_fids(12, gt_col);
    ind_3 = chehra_deva_intraface_rcpr_common_fids(13, gt_col);
    ind_4 = chehra_deva_intraface_rcpr_common_fids(14, gt_col);

    left_eye  = ( gt_fid(ind_1,:) + gt_fid(ind_2,:) )  / 2;
    right_eye = ( gt_fid(ind_3,:) + gt_fid(ind_4,:) )  / 2; 

    if( isnan(left_eye(1,1)) || isnan(right_eye(1,1)) )
        im = imread(face_path);
        int_oc_dist = size(im,2) / 3; 
        return;
    end

    %int_oc_dist = pdist(double([left_eye; right_eye]));
    int_oc_dist = pdist(double([gt_fid(ind_1,:);gt_fid(ind_4,:)]));

end

