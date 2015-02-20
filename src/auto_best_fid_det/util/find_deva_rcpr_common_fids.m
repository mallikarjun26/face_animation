function find_deva_rcpr_common_fids(path)

    %
    fid_deva_lfpw = fopen([path '/common_data/fids_mapping/deva_lfpw_common_fids.txt']);
    fid_rcpr_lfpw   = fopen([path '/common_data/fids_mapping/rcpr_lfpw_common_fids.txt']);
    
    %
    deva_lfpw = get_fid_map(fid_deva_lfpw);
    rcpr_lfpw   = get_fid_map(fid_rcpr_lfpw);

    %
    common_lfpw = intersect(deva_lfpw{1,2}, rcpr_lfpw{1,2}); 
    deva_rcpr_common_fids = zeros(size(common_lfpw,1),2);
    
    for i=1:size(common_lfpw,1)

        par_common_lfpw = common_lfpw(i,1);
        ind_c = find(deva_lfpw{1,2}==par_common_lfpw);
        ind_d = find(rcpr_lfpw{1,2}==par_common_lfpw);
        
        deva_rcpr_common_fids(i,:) = [deva_lfpw{1,1}(ind_c,1) rcpr_lfpw{1,1}(ind_d,1)];
        
    end
    
    save([path '/common_data/fids_mapping/deva_rcpr_common_fids.mat'], 'deva_rcpr_common_fids');
    
end

function x_y = get_fid_map(fid_map)
    x_y = textscan(fid_map, '%u %u', 'HeaderLines', 1);
end