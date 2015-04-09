function generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn)

    %
    close all;
    addpath('../');
    err_margin = 0.1; 
    if(dataset == 'lfpw')
        face_list = [812:1035]';
        all_face_list = [1:1035]';
    elseif(dataset == 'cofw')
        face_list = [1346:1852]';
        all_face_list = [1:1852]';
    elseif(dataset == 'aflw')
        face_list = [1:2500]';
        all_face_list = [1:24386]'; 
    end
    
    %
    [shape_diff, app_diff_avg, app_diff_min] = get_app_measure(path, all_face_list, dataset, 1, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn);    
    selected_models = get_best_model(path, dataset, 1);
    [fail_rate, mean_err, mean_err_parts] = get_failure_rate_and_mean_errors(path, dataset, err_margin);  
    
    %
    h_f = figure;
    generate_bar_graph(fail_rate, 'Failure Rate');
    h_m = figure;
    generate_bar_graph(mean_err, 'Mean Error');
    h_m_p = figure;
    for i=1:size(mean_err_parts, 1);
        subplot(2,10,i);
        generate_bar_graph(mean_err_parts(i, :), ['Part ' num2str(i)]);
    end

    %
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

    save([path '/' dataset '_data/results/' metric_l '_' hog_sift_l '_' kmeans_pca_l '_' shape_app_l num2str(k_in_knn) '_in_knn_results.mat'], 'fail_rate', 'mean_err', 'mean_err_parts');
    saveas(h_f, [path '/' dataset '_data/results/' metric_l '_' hog_sift_l '_' kmeans_pca_l '_' shape_app_l num2str(k_in_knn) '_in_knn_failure_rate_bar_graph.jpg']);
    saveas(h_m, [path '/' dataset '_data/results/' metric_l '_' hog_sift_l '_' kmeans_pca_l '_' shape_app_l num2str(k_in_knn) '_in_knn_mean_error_bar_graph.jpg']);
    saveas(h_m_p, [path '/' dataset '_data/results/' metric_l '_' hog_sift_l '_' kmeans_pca_l '_' shape_app_l num2str(k_in_knn) '_in_knn_mean_error_part_bar_graph.jpg']);

    % if(metric_learning_enabled == 1)
    %     save([path '/' dataset '_data/results/metric_learnt/results.mat'], 'fail_rate', 'mean_err', 'mean_err_parts');
    %     saveas(h_f, [path '/' dataset '_data/results/metric_learnt/failure_rate_bar_graph.jpg']);
    %     saveas(h_m, [path '/' dataset '_data/results/metric_learnt/mean_error_bar_graph.jpg']);
    %     saveas(h_m_p, [path '/' dataset '_data/results/metric_learnt/mean_error_part_bar_graph.jpg']);
    % else
    %     
    %     if(hog_sift_mode == 1)
    %         save([path '/' dataset '_data/results/wo_metric_learnt/results_hog_mode.mat'], 'fail_rate', 'mean_err', 'mean_err_parts');
    %         saveas(h_f, [path '/' dataset '_data/results/wo_metric_learnt/failure_rate_bar_graph_hog_mode.jpg']);
    %         saveas(h_m, [path '/' dataset '_data/results/wo_metric_learnt/mean_error_bar_graph_hog_mode.jpg']);
    %         saveas(h_m_p, [path '/' dataset '_data/results/wo_metric_learnt/mean_error_part_bar_graph_hog_mode.jpg']);
    %     elseif(hog_sift_mode == 2)
    %         save([path '/' dataset '_data/results/wo_metric_learnt/results_sift_mode.mat'], 'fail_rate', 'mean_err', 'mean_err_parts');
    %         saveas(h_f, [path '/' dataset '_data/results/wo_metric_learnt/failure_rate_bar_graph_sift_mode.jpg']);
    %         saveas(h_m, [path '/' dataset '_data/results/wo_metric_learnt/mean_error_bar_graph_sift_mode.jpg']);
    %         saveas(h_m_p, [path '/' dataset '_data/results/wo_metric_learnt/mean_error_part_bar_graph_sift_mode.jpg']);
    %     else
    %         save([path '/' dataset '_data/results/wo_metric_learnt/results.mat'], 'fail_rate', 'mean_err', 'mean_err_parts');
    %         saveas(h_f, [path '/' dataset '_data/results/wo_metric_learnt/failure_rate_bar_graph.jpg']);
    %         saveas(h_m, [path '/' dataset '_data/results/wo_metric_learnt/mean_error_bar_graph.jpg']);
    %         saveas(h_m_p, [path '/' dataset '_data/results/wo_metric_learnt/mean_error_part_bar_graph.jpg']);
    %     end
    % end

end

function generate_bar_graph(data, title_str)

    %
    chehra_c     =  'cyan';  
    deva_c       =  'yellow';
    intraface_c  =  'green';
    rcpr_c       =  'magenta';
    our_c        =  'blue';

    title(title_str);

    bar(1, data(1), chehra_c);
    hold on;
    bar(2, data(2), deva_c);
    hold on;
    bar(3, data(3), intraface_c);
    hold on;
    bar(4, data(4), rcpr_c);
    hold on;
    bar(5, data(5), our_c);

end
