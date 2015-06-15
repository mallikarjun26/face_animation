function [unary_weights, part_near_exemplar] = get_unary_weights(dataset, face_number)

    %
    load(['~/Documents/data/iccv/' dataset '_data/app_based_results/chehra_app_vector.mat']); 
    load(['~/Documents/data/iccv/' dataset '_data/app_based_results/deva_app_vector.mat']); 
    load(['~/Documents/data/iccv/' dataset '_data/app_based_results/intraface_app_vector.mat']); 
    load(['~/Documents/data/iccv/' dataset '_data/app_based_results/rcpr_app_vector.mat']); 
    load(['~/Documents/data/iccv/' dataset '_data/app_based_results/ground_truth_app_vector.mat']); 
    load(['~/Documents/data/iccv/' dataset '_data/sim_image_list_kmeans_shape_en_20_exemplars.mat']); 

    %
    chehra_app = chehra_app_vector{face_number};
    deva_app = deva_app_vector{face_number};
    intraface_app = intraface_app_vector{face_number};
    rcpr_app = rcpr_app_vector{face_number};
    
    exemplars_app = cell(size(sim_list,1),1);
    for i=1:size(sim_list, 1);
        exemplars_app{i} = ground_truth_app_vector{sim_list(i)};    
    end

    %
    methods_parts_score = zeros(4,20);
    part_near_exemplar  = zeros(4,20);

    [methods_parts_score(1,:), part_near_exemplar(1,:)] = get_method_score(chehra_app, exemplars_app, sim_list);
    [methods_parts_score(2,:), part_near_exemplar(2,:)] = get_method_score(deva_app, exemplars_app, sim_list);
    [methods_parts_score(3,:), part_near_exemplar(3,:)] = get_method_score(intraface_app, exemplars_app, sim_list);
    [methods_parts_score(4,:), part_near_exemplar(4,:)] = get_method_score(rcpr_app, exemplars_app, sim_list);

    inf_t = find(isinf(methods_parts_score(:)));
    max_t = max(methods_parts_score(find(~isinf(methods_parts_score(:)))));
    methods_parts_score(inf_t) = max_t;
    
    methods_parts_score = ( methods_parts_score - min(methods_parts_score(:)) ) / range(methods_parts_score(:));

    methods_parts_score = methods_parts_score';
    
    unary_weights = methods_parts_score(:);    

end

function [method_parts_score, part_near_exemplar]= get_method_score(method_app, exemplars_app, sim_list)

    method_parts_score = Inf * ones(1,20);
    part_near_exemplar = zeros(1,20);

    for i=1:20 % parts
        for j=1:20 % exemplars
            exemplar_app = exemplars_app{j};
            temp_score = pdist([method_app{i}; exemplar_app{i}]);
            if( method_parts_score(i) > temp_score)
                method_parts_score(i) = temp_score;
                part_near_exemplar(i) = sim_list(j);
            end
        end
    end

end
