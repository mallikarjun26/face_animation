function feasible_global_models = choose_global_models(global_fiducials, local_prob, filtered_size, im, path)

    %
    r = 10000;  % Number of iterations
    g = 10;      % Number of top scores for each part
    m = 100;    % Number of global selctions
    
    number_of_exemplars = size(global_fiducials, 1);
    number_of_parts     = size(local_prob,1);
    number_of_random_parts = 2;

    %
    % global_fiducials = normalize_shape_models(global_fiducials, image_size);

    L = r*g*g;
    temp_feasible_global_models = cell(L, 1);
    temp_global_models_score    = zeros(L, 1);
    temp_exemplars_id           = zeros(L, 1);
    tr_dist                     = zeros(L, 1);
   
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
        
        random_selected_parts_index = randi([1 size(selected_parts,2)], 1, number_of_random_parts);
        random_parts = zeros(1,number_of_random_parts);
        for ii=1:number_of_random_parts
            random_parts(1, ii) =  selected_parts(random_selected_parts_index(1,ii));
        end
        
        %random_parts = randi([18 68], 1, 2);
        X  = zeros(number_of_random_parts, 2);
        Y  = zeros(number_of_random_parts, 2);
        
        % select one of the g high scoring locations for each of two parts
        index_ii = zeros(length(local_prob{1}(:)), number_of_random_parts);
        for ii=1:number_of_random_parts
            part_ii_prob_map    = local_prob{random_parts(1,ii)};
            [~, index_temp]       = sort(part_ii_prob_map(:), 'descend'); 
            index_ii(:,ii) = index_temp;
        end
        
        for ii=1:number_of_random_parts
            Y(ii,:) = double( exemplar(random_parts(1,ii), :));
        end
        
        for j=1:g
            for k=1:g
                l = ((i-1)*g*g) + ((j-1)*g) + k;
                
                [a, b] = ind2sub(filtered_size, index_ii(j,1));
                X(1,:) = [a b];
                [a, b] = ind2sub(filtered_size, index_ii(k,2));
                X(2,:) = [a b];
                
                % find the transformation
                % Use the transformed global positions to find the score.
                flag = false;
                %[d,Z,tr] = procrustes(X,Y,'reflection',flag);
                [d,Z,tr] = do_st(X, Y);
                tr_dist(l, 1) = d;
                
                transformed_model = tr.b* double(exemplar) *tr.T ;
                transformed_model = transformed_model + tr.c(1,1);
                transformed_model = transformed_model + tr.c(1,2);

                y1 = min(transformed_model(:,1));
                x1 = min(transformed_model(:,2));

                y2 = max(transformed_model(:,1));
                x2 = max(transformed_model(:,2));

                width = x2 - x1;
                height = y2 - y1;
                
                if( (y1>1) && (x1>1) && (y2<filtered_size(1,1)) && (x2<filtered_size(1,2)) && (width > 0.7*filtered_size(1,2)) && (height > 0.7*filtered_size(1,1))) 
                    success = success +1;
                    transformed_model = uint32(transformed_model);

                    temp_feasible_global_models{l,1} = transformed_model;
                    temp_global_models_score(l,1)    = get_exemplar_score(transformed_model, local_prob, filtered_size);
                    temp_exemplars_id(l, 1)          = random_exemplars;

                else

                    temp_feasible_global_models{l,1} = [];
                    temp_global_models_score(l,1) = 0;

                end
            end
        end
       
    end
    
    [high_score score_index] = sort(temp_global_models_score, 'descend');
    
    m = min(m, success);
    feasible_global_models = cell(m,1);
    final_distances = zeros(m,1);
    for i=1:m
        feasible_global_models{i,1} = temp_feasible_global_models{score_index(i,1)};
        final_distances(i,1) = tr_dist(score_index(i,1), 1);
        fig_h = plot_fiducials(im, feasible_global_models{i,1});
        image_file_name = [path '/top_globals_selected/' num2str(i) '.jpg'];
        saveas(fig_h, image_file_name);
        close(fig_h);
    end
    
    save([path '/intermediate_results/final_tr_distances.mat'], 'final_distances');
    
end

function [d,Z,tr] = do_st(X, Y)

    ty = mean(X(:,1)) - mean(Y(:,1));
    tx = mean(X(:,2)) - mean(Y(:,2));
  
    s = sum( X(:,1).*Y(:,1)   +   X(:,2).*Y(:,2)) ;
    s = s /  sum((Y(:,1).^2   +   Y(:,2).^2));
    
    tr.c = [ty tx]; 
    tr.T = [1 0; 0 1];
    tr.b = s;
    
    d = 0;
    Z = 0;
    
end

function [score, db_score] = get_exemplar_score(exemplar, local_prob, filtered_size)

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
    
    db_score = db_score / (1/prod(filtered_size));
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

