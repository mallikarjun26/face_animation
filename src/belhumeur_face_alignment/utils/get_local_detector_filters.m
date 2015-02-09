% Given model of Deva Ramanan, map_file indicating part number correspondances, saves the filters 

function get_local_detector_filters(model, map_file, output_path)

    %
    fid = fopen(map_file);
    number_of_local_filters = 68;
    
    %
    deva_train_map = textscan(fid, '%u %u', 'HeaderLines', 1);
    local_filters = cell(number_of_local_filters, 1);
    mc_7 = model.components{7};
    
    %
    for i=1:number_of_local_filters
        
        index = deva_train_map{2}(i,1);
        act_filter_index = mc_7(i).filterid;
        local_filters{index,1} = model.filters(act_filter_index);
        
    end
    
    %
    save([output_path '/intermediate_results/local_filters.mat'], 'local_filters');
    
end
