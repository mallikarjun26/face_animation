function output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars)

    if(metric_learning_enabled)
       metric_l = 'met_en';
    else
       metric_l = 'met_di';
    end

    if(hog_sift_mode == 1)
        hog_sift_l = 'hog_en';
    elseif(hog_sift_mode == 2)
        hog_sift_l = 'sift_en';
    else
        hog_sift_l = 'hog_sift_en';
    end

    if(kmeans_pca_mode == 1)
        kmeans_pca_l = 'kmeans_en';
    else
        kmeans_pca_l = 'pca_en';
    end
    if(shape_app_mode == 1)
        shape_app_l = 'shape_en_';
    else
        shape_app_l = 'app_en_';
    end

    output_file_name = [metric_l '_' hog_sift_l '_' kmeans_pca_l '_' shape_app_l num2str(k_in_knn) '_in_knn_' num2str(num_of_exemplars) '_exemplars_results.mat'];

end