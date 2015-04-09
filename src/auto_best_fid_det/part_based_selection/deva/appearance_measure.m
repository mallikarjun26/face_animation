function appearance_measure(input_path)

    %
    load([input_path '/intermediate_results/appearance_features.mat']);
    load('face_p99.mat');

    %
    lbp_feat_size = 2 * 2 * 58;
    number_of_top_scorers = 15;
    number_of_nodes  = size(appearance_features, 1);
    appearance_graph = Inf * ones(number_of_nodes, number_of_nodes); 
    
    %
    tic;
    for i=1:number_of_nodes
        
        disp([num2str(i) '/' num2str(number_of_nodes) 'outer nodes done ..']);
        
        for j=i+1:number_of_nodes

            if(isempty(appearance_features{i}))
                appearance_graph(i,j) = Inf; 
                appearance_graph(j,i) = Inf; 
                continue;
            end
            
            if(isempty(appearance_features{j}))
                appearance_graph(i,j) = Inf; 
                appearance_graph(j,i) = Inf; 
                continue;
            end
            
            c_1 = appearance_features{i}.c;
            c_2 = appearance_features{j}.c;
            
            if(abs(c_1-c_2) > 3)
               appearance_graph(i,j) = Inf; 
               appearance_graph(j,i) = Inf; 
            end
            
            id_1 = [model.components{c_1}.filterid];
            id_2 = [model.components{c_2}.filterid];
            
            feat_1 = zeros(99, lbp_feat_size);
            feat_2 = zeros(99, lbp_feat_size);
            
            feat_1(id_1,:) = appearance_features{i}.feat;
            feat_2(id_2,:) = appearance_features{j}.feat;
            
            id_c = intersect(id_1, id_2);
            number_of_common_components = size(id_c, 2);
            parts_distances = zeros(1, number_of_common_components);
            
            for k=1:number_of_common_components
               parts_distances(k,1) = pdist([ feat_1(id_c(1,k),:) ; feat_2(id_c(1,k),:) ]);
            end
            
            parts_distances = sort(parts_distances);
            
            dist = sum(parts_distances(1:number_of_top_scorers)) / number_of_top_scorers;
            appearance_graph(i,j) = dist;
            appearance_graph(j,i) = dist;
            
        end
    end
    toc
    
    save([ input_path '/intermediate_results/appearance_graph.mat'], 'appearance_graph');
    
end