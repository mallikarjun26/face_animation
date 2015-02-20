function find_chehra_deva_rcpr_common_fids(path)

    %
    fid_chehra_lfpw = fopen([path '/common_data/fids_mapping/chehra_lfpw_common_fids.txt']);
    fid_deva_lfpw   = fopen([path '/common_data/fids_mapping/deva_lfpw_common_fids.txt']);
    fid_rcpr_lfpw   = fopen([path '/common_data/fids_mapping/rcpr_lfpw_common_fids.txt']);
    
    %
    chehra_lfpw = get_fid_map(fid_chehra_lfpw);
    deva_lfpw   = get_fid_map(fid_deva_lfpw);
    rcpr_lfpw   = get_fid_map(fid_rcpr_lfpw);

    %
    common_lfpw = intersect(chehra_lfpw{1,2}, deva_lfpw{1,2}); 
    common_lfpw = intersect(common_lfpw, rcpr_lfpw{1,2});
    chehra_deva_rcpr_common_fids = zeros(size(common_lfpw,1),3);
    
    for i=1:size(common_lfpw,1)

        par_common_lfpw = common_lfpw(i,1);
        ind_c = find(chehra_lfpw{1,2}==par_common_lfpw);
        ind_d = find(deva_lfpw{1,2}==par_common_lfpw);
        ind_r = find(rcpr_lfpw{1,2}==par_common_lfpw);
        
        chehra_deva_rcpr_common_fids(i,:) = [chehra_lfpw{1,1}(ind_c,1) deva_lfpw{1,1}(ind_d,1) rcpr_lfpw{1,1}(ind_r,1)];
        
    end
    
    save([path '/common_data/fids_mapping/chehra_deva_rcpr_common_fids.mat'], 'chehra_deva_rcpr_common_fids');
    
end

function x_y = get_fid_map(fid_map)
    x_y = textscan(fid_map, '%u %u', 'HeaderLines', 1);
end