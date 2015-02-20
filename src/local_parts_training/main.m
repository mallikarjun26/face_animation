function main(path)

    %
    clc;

    %
    load([path '/belhumeur_data/intermediate_results/global_model_map.mat']);
    load([path '/belhumeur_data/intermediate_results/global_fiducials.mat']);
    
    %
    tic;
    disp('Extract patches for each of the parts');
    if(~isempty([path '/belhumeur_data/local_parts_training/part_patches.mat']))
        [pos_part_patches, neg_part_patches] = get_part_patches(global_model_map, global_fiducials);
        save([path '/belhumeur_data/local_parts_training/pos_part_patches.mat'], 'pos_part_patches');
        save([path '/belhumeur_data/local_parts_training/neg_part_patches.mat'], 'neg_part_patches');
    else
        load([path '/belhumeur_data/local_parts_training/pos_part_patches.mat']);
        load([path '/belhumeur_data/local_parts_training/neg_part_patches.mat']);
    end
    disp(['Time taken ' num2str(toc)]);
    
    %
    tic
    disp('Getting feature vectors ....');
    if(~isempty([path '/belhumeur_data/local_parts_training/feature_vector.mat']))
        pos_feature_vector = get_feature_vector(pos_part_patches);
        save([path '/belhumeur_data/local_parts_training/pos_feature_vector.mat'], 'pos_feature_vector');
        clear pos_part_patches;
        neg_feature_vector = get_feature_vector(neg_part_patches);
        save([path '/belhumeur_data/local_parts_training/neg_feature_vector.mat'], 'neg_feature_vector');
        clear neg_part_patches;
    else
        load([path '/belhumeur_data/local_parts_training/pos_feature_vector.mat']);
        load([path '/belhumeur_data/local_parts_training/neg_feature_vector.mat']);
    end
    disp(['Time taken ' num2str(toc)]);
    
    %
    tic
    disp('SVM training with RBF kernel ....');
    trained_models = get_trained_models(pos_feature_vector, neg_feature_vector);
    save([path '/belhumeur_data/local_parts_training/trained_models.mat'], 'trained_models');
    disp(['Time taken ' num2str(toc)]);
    
end