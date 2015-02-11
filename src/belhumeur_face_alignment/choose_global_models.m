function feasible_global_models = choose_global_models(global_fiducials, local_prob, image_size, im, path)

    %
    r = 10000;
    g = 2;
    m = 100;
    
    number_of_exemplars = size(global_fiducials, 1);
    number_of_parts     = size(local_prob,1);

    %
    global_fiducials = normalize_shape_models(global_fiducials, image_size);
        
    temp_feasible_global_models = cell(r, 1);
    temp_global_models_score    = zeros(r, 1);
    temp_exemplars_id           = zeros(r, 1);
   
    %
    success = 0;
    for i=1:r
        
        % select a random exemplar
        random_exemplars    = round( (rand * (number_of_exemplars-1)) ) + 1;
        exemplar            = global_fiducials{random_exemplars};
        
        % select two random parts 
        %random_parts = randi([1 68], 1, 2);
        
        selected_parts = [2     3     4     5     6     7     8     9    10    11    12    13    14    15 ...
                          21   22    24    25    28    37    39    40    41    42    45    46    49    59    61   64   68];
        
        random_selected_parts_index = randi([1 size(selected_parts,2)], 1, 2);
                      
        random_parts = [selected_parts(random_selected_parts_index(1,1)) selected_parts(random_selected_parts_index(1,2))];
        %random_parts = randi([18 68], 1, 2);
        selected_locations  = zeros(2, 2);
        
        % select one of the g high scoring locations for each of two parts
        part_1_prob_map = local_prob{random_parts(1,1)};
        part_2_prob_map = local_prob{random_parts(1,2)};

        [v index]           = sort(part_1_prob_map(:), 'descend');
        random_index    = round(rand * (g-1)) + 1;
        [a, b] = ind2sub(image_size, index(random_index,1));
        selected_locations(1,:) = [a b];    
        
        [v index]           = sort(part_2_prob_map(:), 'descend');
        random_index    = round(rand * (g-1)) + 1;
        [a, b] = ind2sub(image_size, index(random_index,1));
        selected_locations(2,:) = [a b];
        
        % find the transformation
        % Use the transformed global positions to find the score.
        
        X = double(selected_locations);
        Y = double([ exemplar(random_parts(1,1), :) ; exemplar(random_parts(1,2), :) ]);
        
        [d,Z,tr] = procrustes(X,Y);
         
        transformed_model = tr.b* double(exemplar) *tr.T ;
        transformed_model = transformed_model + tr.c(1,1);
        transformed_model = transformed_model + tr.c(1,2);
        
        y1 = min(transformed_model(:,1));
        x1 = min(transformed_model(:,2));
        
        y2 = max(transformed_model(:,1));
        x2 = max(transformed_model(:,2));
        
        if(random_exemplars == 1)
           disp('Its a hit!!'); 
        end
        
        
        if( (y1>1) && (x1>1) && (y2<image_size(1,1)) && (x2<image_size(1,2)) ) 
            success = success +1;
            transformed_model = uint32(transformed_model);
            
            temp_feasible_global_models{i,1} = transformed_model;
            temp_global_models_score(i,1)    = get_exemplar_score(transformed_model, local_prob, image_size);
            temp_exemplars_id(i, 1)          = random_exemplars;

        else
            
            temp_feasible_global_models{i,1} = [];
            temp_global_models_score(i,1) = 0;
            db_exemplar_scores{i,1} = [];

        end
        
    end
    
    [high_score score_index] = sort(temp_global_models_score, 'descend');
    
    m = min(m, success);
    feasible_global_models = cell(m,1);
    for i=1:m
        feasible_global_models{i,1} = temp_feasible_global_models{score_index(i,1)};
        
        fig_h = plot_fiducials(im, feasible_global_models{i,1});
        image_file_name = [path '/top_globals_selected_with_selected_parts/' num2str(i) '.jpg'];
        saveas(fig_h, image_file_name);
        close(fig_h);
    end
    
end

function [score, db_score] = get_exemplar_score(exemplar, local_prob, image_size)

    %
    
    %
    number_of_parts = size(local_prob, 1);
    score = 1;
    db_score = zeros(number_of_parts, 1);
    
    for i=1:number_of_parts
        temp_part_prob_res = local_prob{i,1};
        y = exemplar(i,1);
        x = exemplar(i,2);
        score = score * temp_part_prob_res(y, x);
        db_score(i,1) = temp_part_prob_res(y, x);
    end
    
    db_score = db_score / (1/prod(image_size));
    score = prod(db_score);
    
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

