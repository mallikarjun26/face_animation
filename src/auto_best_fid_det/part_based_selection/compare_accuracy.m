function [fail_rate, mean_err, mean_err_parts, failed_list] = compare_accuracy(path, dataset, face_list, err_margin)

    %
    if(dataset == 'lfpw')
        gt_col    = 7;
    elseif(dataset == 'cofw')
        gt_col    = 8;
    elseif(dataset == 'aflw')
        gt_col    = 9;
    end
    
    %
    load([path '/' dataset '_data/facemap.mat']);
    load([path '/' dataset '_data/ground_truth.mat']);
    load([path '/' dataset '_data/deva_fids.mat']);
    load([path '/' dataset '_data/modi_deva_fids.mat']);
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);

    %
    number_of_samples = size(face_list, 1);
    d_err = cell(number_of_samples, 1);
    m_d_err = cell(number_of_samples, 1);

    %
    for i=1:number_of_samples 
        
        face_num = face_list(i);
        
        d_fids = deva_fids{face_num};            
        m_d_fids = modi_deva_fids{face_num};            
        gt_fids = ground_truth{face_num};
        if(isempty(d_fids))
            d_fids.xy = NaN * ones(68,4);
            d_fids.c = 7;
        end
        if(isempty(m_d_fids))
            m_d_fids.xy = NaN * ones(68,4);
            m_d_fids.c = 7;
        end
        
        int_oc_dist = get_int_oc_dist(gt_fids, gt_col, chehra_deva_intraface_rcpr_common_fids, facemap{face_num});

        [d_err{i}, m_d_err{i}] = get_error(gt_fids, d_fids, m_d_fids, int_oc_dist, chehra_deva_intraface_rcpr_common_fids, gt_col);
        
    end
    [d_fail_rate, m_d_fail_rate, failed_list] = get_failure_rate(d_err, m_d_err, err_margin); 
    [d_mean_err, m_d_mean_err] = get_mean_error(d_err, m_d_err, err_margin); 

    fail_rate       = [d_fail_rate, m_d_fail_rate];
    mean_err_parts  = [d_mean_err m_d_mean_err];
    mean_err        = [mean(d_mean_err(find(~isnan(d_mean_err)))) mean(m_d_mean_err(find(~isnan(m_d_mean_err))))];
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

function [d_err, m_d_err] = get_error(gt_fid, d_fid, m_d_fid, int_oc_dist, chehra_deva_intraface_rcpr_common_fids, gt_col)

    num_of_parts = size(chehra_deva_intraface_rcpr_common_fids, 1);
    d_err = NaN * ones(num_of_parts, 1);    
    m_d_err = NaN * ones(num_of_parts, 1);    
    
    d_fid_o = d_fid;
    m_d_fid_o = m_d_fid;
    
    gt_fid = get_fid(gt_fid, gt_col, chehra_deva_intraface_rcpr_common_fids);
    d_fid  = get_fid(d_fid, 2, chehra_deva_intraface_rcpr_common_fids);
    m_d_fid  = get_fid(m_d_fid, 2, chehra_deva_intraface_rcpr_common_fids);

    for i=1:num_of_parts
        
        if(isnan(chehra_deva_intraface_rcpr_common_fids(i,gt_col)))
            d_err(i) = NaN; 
            m_d_err(i) = NaN;     
            continue;
        end
        
        d_err(i) = pdist([d_fid(i,:); gt_fid(i,:)]) / int_oc_dist; 
        m_d_err(i) = pdist([m_d_fid(i,:); gt_fid(i,:)]) / int_oc_dist; 

        if(isnan(d_fid(i,1)) && (d_fid_o.c==7))
            d_err(i) = 0.1;
        end
        if(isnan(m_d_fid(i,1)) && (m_d_fid_o.c==7))
            m_d_err(i) = 0.1;
        end
    end

end

function [d_fail_rate, m_d_fail_rate, failed_list] = get_failure_rate(d_err, m_d_err, err_margin)
    
    num_of_samples = size(d_err, 1); 
    d_fail_rate = 0;
    m_d_fail_rate = 0;

    deva_failed_list = [];
    modi_deva_failed_list = [];
    
    for i=1:num_of_samples

        d_t = did_fail(d_err{i}, err_margin);    
        d_fail_rate = d_fail_rate + d_t;
        
        m_d_t = did_fail(m_d_err{i}, err_margin);
        m_d_fail_rate = m_d_fail_rate + m_d_t;
        
        if(d_t)
            deva_failed_list = [deva_failed_list; i];
        end
        if(m_d_t)
            modi_deva_failed_list = [modi_deva_failed_list; i];
        end
                
    end

    failed_list.deva_failed_list = deva_failed_list;
    failed_list.modi_deva_failed_list = modi_deva_failed_list;
    
    d_fail_rate = d_fail_rate / num_of_samples;
    m_d_fail_rate = m_d_fail_rate / num_of_samples;
    
end

function [d_mean_err, m_d_mean_err] = get_mean_error(d_err, m_d_err, err_margin)

    num_of_samples = size(d_err, 1);
    num_of_parts   = size(d_err{1}, 1);
    d_mean_err = zeros(num_of_parts,2);
    m_d_mean_err = zeros(num_of_parts,2);

    for i=1:num_of_samples
        d_err_t = d_err{i}; 
        m_d_err_t = m_d_err{i}; 
        for j=1:num_of_parts
            if(~isnan(d_err_t(j)))
                d_mean_err(j,1) = d_mean_err(j,1) + d_err_t(j);
                d_mean_err(j,2) = d_mean_err(j,2) + 1;
            end
            if(~isnan(m_d_err_t(j)))
                m_d_mean_err(j,1) = m_d_mean_err(j,1) + m_d_err_t(j);
                m_d_mean_err(j,2) = m_d_mean_err(j,2) + 1;
            end
        end         
    end

    d_mean_err = d_mean_err(:,1) ./ d_mean_err(:,2);
    m_d_mean_err = m_d_mean_err(:,1) ./ m_d_mean_err(:,2);

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
