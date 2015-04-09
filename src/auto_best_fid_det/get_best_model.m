function selected_models = get_best_model(path, dataset, auto_train_select)

    %
    if(dataset == 'jack')
        load([path '/' dataset '_data/app_based_results/app_based_results_auto.mat']);
        load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
    else
        load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
        if(auto_train_select == 1)
            load([path '/' dataset '_data/app_based_results/app_based_results_auto.mat']);
        else
            load([path '/' dataset '_data/app_based_results/app_based_results_manual.mat']);
        end
    end

    %
    number_of_faces = size(app_diff_min,1);
    selected_models = zeros(number_of_faces, 1);

    %
    for i=1:number_of_faces
        selected_model_t = 1;
        min_app = app_diff_min{i}.app_chehra;
        if(min_app > app_diff_min{i}.app_deva)
            min_app = app_diff_min{i}.app_deva;
            selected_model_t = 2;
        end
        if(min_app > app_diff_min{i}.app_intraface)
            min_app = app_diff_min{i}.app_intraface;
            selected_model_t = 3;
        end
        if(min_app > app_diff_min{i}.app_rcpr)
            min_app = app_diff_min{i}.app_rcpr;
            selected_model_t = 4;
        end

        selected_models(i) = selected_model_t;
    end

    %
    save([path '/' dataset '_data/app_based_results/selected_models.mat'], 'selected_models');

end
