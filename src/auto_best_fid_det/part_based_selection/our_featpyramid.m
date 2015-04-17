function our_resp = our_featpyramid(heat_map, path) 

    %
    load('results/resp.mat');
    load('deva/face_p99.mat');
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
    
    %
    num_of_levels = size(resp, 1);
    our_resp = cell(num_of_levels, 1);
    map_68_99_c = [model.components{7}.filterid];   
    map_39_99_l = [model.components{1}.filterid];   
    map_39_99_r = [model.components{13}.filterid];   
    
    %
    for i=1:num_of_levels
        if(isempty(resp{i}))
            our_resp{i} = [];
            continue;
        end

        num_of_resp = size(resp{i}, 2);
        resp_t = cell(1, num_of_resp) ;
        filters_resp = resp{i};
        resp_size = size(filters_resp{1});

        for j=1:num_of_resp
            map_68_20_c = []; map_68_20_l = []; map_68_20_r = []; 
            deva_part_id_c = find(map_68_99_c == j);
            deva_part_id_l = find(map_39_99_l == j);
            deva_part_id_r = find(map_39_99_r == j);

            if(isempty(deva_part_id_c) && isempty(deva_part_id_l) && isempty(deva_part_id_r))
                continue;
            end

            if(~isempty(deva_part_id_c))
                map_68_20_c = find(chehra_deva_intraface_rcpr_common_fids(:,2) == deva_part_id_c);
            end
            if(~isempty(deva_part_id_l))
                map_68_20_l = find(chehra_deva_intraface_rcpr_common_fids(:,5) == deva_part_id_l);
            end
            if(~isempty(deva_part_id_r))
                map_68_20_r = find(chehra_deva_intraface_rcpr_common_fids(:,6) == deva_part_id_r);
            end

            if(isempty(map_68_20_c) && isempty(map_68_20_l) && isempty(map_68_20_r))
                continue;
            end

            if(~isempty(map_68_20_c))
                heat_map_t = heat_map{map_68_20_c};
            elseif(~isempty(map_68_20_l))
                heat_map_t = heat_map{map_68_20_l};
            else
                heat_map_t = heat_map{map_68_20_r};
            end

            resp_t{j} = imresize(heat_map_t, resp_size);
        end
        our_resp{i} = resp_t;
    end

    % resp = our_resp;
    % save('../../results/our_resp.mat', 'resp');
end

