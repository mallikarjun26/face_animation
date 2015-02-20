function trained_models = get_trained_models(pos_feature_vector, neg_feature_vector)

    %
    number_of_parts = size(pos_feature_vector,1);
    trained_models = cell(number_of_parts,1);
    
    %
    for i=1:number_of_parts
       
        features = [pos_feature_vector{i,1} ; neg_feature_vector{i,1}];
        groups = ones(size(pos_feature_vector,1),1);
        groups = [groups; -1*ones(size(neg_feature_vector,1),1)];
        model = svmtrain(features, groups, 'Kernel_Function', 'rbf', 'RBF_Sigma', 1);
        trained_models{i,1} = model;
        
    end
    
    
end