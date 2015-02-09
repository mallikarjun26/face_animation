function feasible_global_models = choose_global_models(global_fiducials, local_prob, image_size)

    %
    r = 100;
    g = 2;
    m = 100;
    
    number_of_exemplars = size(global_fiducials, 1);
    number_of_parts     = size(local_prob,1);

    %
    global_fiducials = normalize_shape_models(global_fiducials, image_size);
    feasible_global_models = cell(m, 1);
    
    temp_feasible_global_models = cell(r, 1);
    temp_global_models_score    = zeros(r, 1);
    
    %
    for i=1:r
        
        % select a random exemplar
        random_exemplars    = round( (rand * (number_of_exemplars-1)) ) + 1;
        exemplar            = global_fiducials{random_exemplars};
        
        % select two random parts 
        random_parts        = round(rand(1, 2) * (number_of_parts-1)) + 1;
        selected_locations  = zeros(2, 2);
        
        % select one of the g high scoring locations for each of two parts
        part_1_prob_map = local_prob{random_parts(1,1)};
        part_2_prob_map = local_prob{random_parts(1,2)};

        [v index]           = sort(part_1_prob_map(:), 'descend');
        random_index    = round(rand * (g-1)) + 1;
        selected_locations(1,:) = ind2sub(image_size, index(random_index,1));
            
        [v index]           = sort(part_2_prob_map(:), 'descend');
        random_index    = round(rand * (g-1)) + 1;
        selected_locations(2,:) = ind2sub(image_size, index(random_index,1));
        
        % find the transformation
        % Use the transformed global positions to find the score.
        temp_feasible_global_models{i,1} = exemplar;
        temp_global_models_score(i,1)    = get_exemplar_score(exemplar, local_prob);
         
    end
    
    [high_score score_index] = sort(temp_global_models_score, 'descend');
    
    for i=1:m
        feasible_global_models{i,1} = temp_feasible_global_models{score_index(i,1)};
    end
    
end

function score = get_exemplar_score(exemplar, local_prob)

    %
    
    %
    number_of_parts = size(local_prob, 1);
    score = 1;
    
    for i=1:number_of_parts
        temp_part_prob_res = local_prob{i,1};
        y = exemplar(i,1);
        x = exemplar(i,2);
        score = score * temp_part_prob_res(y, x);
    end
end


function global_fiducials = normalize_shape_models(global_fiducials, image_size)

    %
    number_of_exemplars = size(global_fiducials, 1);

    %
    for i=1:number_of_exemplars
        example = global_fiducials{i};
        min_x = min(example(:, 1));
        min_y = min(example(:, 2));
        max_x = max(example(:, 1));
        max_y = max(example(:, 2));
        
        width   = (max_x - min_x) + 1;
        height  = (max_y - min_y) + 1;
        
        example(:,1) = min( uint32(( double( example(:,1) - min_x ) / double(width) ) * double(image_size(1,2))) + 1, image_size(1,1)) ;
        example(:,2) = min( uint32(( double( example(:,2) - min_y ) / double(height) ) * double(image_size(1,1))) + 1, image_size(1,2));
        
        global_fiducials{i} = example;
    end
    
end

