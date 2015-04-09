function our_featpyramid(path, dataset) 

    %
    load('../../results/heat_map.mat');
    load('../../results/resp.mat');
    load('../face_p99.mat');
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
    
    %
    num_of_levels = size(resp, 1);
    our_resp = cell(num_of_levels, 1);
    map_68_99 = [model.components{7}.filterid];   
    
    %
    for i=1:num_of_levels
        resp_t = resp{i};
        if(isempty(resp_t))
            our_resp{i} = [];
            continue;
        end
        
        num_of_resp = size(resp_t, 2);
        resp_size = size(resp_t{1});
        for j=1:num_of_resp
            deva_part_id = find(map_68_99 == j);
            if(isempty(deva_part_id))
                %resp_t{j} = ones(resp_size) / (resp_size(1,1) * resp_size(1,2));
                resp_t{j} = [];
                continue;
            end
            map_68_20 = find(chehra_deva_intraface_rcpr_common_fids(:,2) == deva_part_id);
            if(isempty(map_68_20))
                %resp_t{j} = ones(resp_size) / (resp_size(1,1) * resp_size(1,2));
                resp_t{j} = [];
                continue;
            end
            heat_map_t = heat_map{map_68_20};
            resp_t{j} = imresize(heat_map_t, resp_size);
            resp_t{j} = normalize_heat_map(resp_t{j});
        end
        our_resp{i} = resp_t;
    end

    resp = our_resp;
    %
    save('../../results/our_resp.mat', 'resp');
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