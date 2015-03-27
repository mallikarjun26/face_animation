function find_chehra_deva_intraface_rcpr_common_fids(path)

    %
    fid_chehra_lfpw = fopen([path '/common_data/fids_mapping/chehra_lfpw_common_fids.txt']);
    fid_deva_lfpw   = fopen([path '/common_data/fids_mapping/deva_lfpw_common_fids.txt']);
    fid_intraface_lfpw   = fopen([path '/common_data/fids_mapping/intraface_lfpw_common_fids.txt']);
    fid_rcpr_lfpw   = fopen([path '/common_data/fids_mapping/rcpr_lfpw_common_fids.txt']);
    fid_deva_ex_left_lfpw   = fopen([path '/common_data/fids_mapping/deva_ex_left_lfpw_common_fids.txt']);
    fid_deva_ex_right_lfpw   = fopen([path '/common_data/fids_mapping/deva_ex_right_lfpw_common_fids.txt']);
    
    %
    chehra_lfpw = get_fid_map(fid_chehra_lfpw);
    deva_lfpw   = get_fid_map(fid_deva_lfpw);
    intraface_lfpw   = get_fid_map(fid_intraface_lfpw);
    rcpr_lfpw   = get_fid_map(fid_rcpr_lfpw);
    deva_ex_left_lfpw   = get_fid_map(fid_deva_ex_left_lfpw);
    deva_ex_right_lfpw   = get_fid_map(fid_deva_ex_right_lfpw);

    %
    common_lfpw = intersect(chehra_lfpw{1,2}, deva_lfpw{1,2}); 
    common_lfpw = intersect(common_lfpw, rcpr_lfpw{1,2});
    common_lfpw = intersect(common_lfpw, intraface_lfpw{1,2});

    chehra_deva_intraface_rcpr_common_fids = zeros(size(common_lfpw,1), 10);
    cofw_ground_truth = [ 1 5 3 4 7 2 21 19 22 20 9 11 12 10 23 25 24 28 26 27 ]';
    aflw_ground_truth = [ 1 2 3 4 5 6 15 14 NaN 16 7 9 10 12 18 NaN 20 NaN NaN NaN ]';
    aflw_ground_truth_com = [ 1 2 3 4 5 6 15 14 44 16 7 9 10 12 18 56 20 61 19 70 ]';
    
    for i=1:size(common_lfpw,1)

        par_common_lfpw = common_lfpw(i,1);
        ind_c = find(chehra_lfpw{1,2}==par_common_lfpw);
        ind_d = find(deva_lfpw{1,2}==par_common_lfpw);
        ind_i = find(intraface_lfpw{1,2}==par_common_lfpw);
        ind_r = find(rcpr_lfpw{1,2}==par_common_lfpw);
        
        ind_dl = find(deva_ex_left_lfpw{1,2}==par_common_lfpw);
        if(isempty(ind_dl))
            ind_dl = NaN;
        else
            ind_dl = deva_ex_left_lfpw{1,1}(ind_dl,1);
        end
        
        ind_dr = find(deva_ex_right_lfpw{1,2}==par_common_lfpw);
        if(isempty(ind_dr))
            ind_dr = NaN;
        else
            ind_dr = deva_ex_right_lfpw{1,1}(ind_dr,1);
        end
        
        chehra_deva_intraface_rcpr_common_fids(i,:) = [double(chehra_lfpw{1,1}(ind_c,1)) double(deva_lfpw{1,1}(ind_d,1)) double(intraface_lfpw{1,1}(ind_i,1)) double(rcpr_lfpw{1,1}(ind_r,1)) double(ind_dl) double(ind_dr) double(par_common_lfpw) double(0) double(0) double(0)];
        
    end
    
    chehra_deva_intraface_rcpr_common_fids(:,8) = cofw_ground_truth; 
    chehra_deva_intraface_rcpr_common_fids(:,9) = aflw_ground_truth; 
    chehra_deva_intraface_rcpr_common_fids(:,10) = aflw_ground_truth_com; 
    save([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat'], 'chehra_deva_intraface_rcpr_common_fids');
    
end

function x_y = get_fid_map(fid_map)
    x_y = textscan(fid_map, '%u %u', 'HeaderLines', 1);
end
