function [auto_results, manual_results] = comp_auto_manual_results(path, dataset, mode, metric_learning_enabled)

    addpath('./../');

    %
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

    err_thresh = [1:0.5:4]';
    auto_results = zeros(size(err_thresh,1), 5);
    manual_results = zeros(size(err_thresh,1), 5);

    if(mode==1 || mode==3)
%         if(exist([path '/' dataset '_data/app_based_results/app_based_results_auto.mat']))
%             load([path '/' dataset '_data/app_based_results/app_based_results_auto.mat']);
%         else
            [shape_diff, app_diff_avg, app_diff_min] = get_app_measure(path, all_face_list, dataset, 1, metric_learning_enabled);    
%         end
        for i=1:size(err_thresh,1)
            thresh = err_thresh(i);
            [chehra_accuracy, deva_accuracy, intraface_accuracy, rcpr_accuracy, our_model_accuracy] = get_model_accuracies(path, face_list, dataset, thresh, 1);
            auto_results(i,:) = [chehra_accuracy, deva_accuracy, intraface_accuracy, rcpr_accuracy, our_model_accuracy];
        end
    end

    if(mode==2 || mode==3)
        if(exist([path '/' dataset '_data/app_based_results/app_based_results_manual.mat']))
            load([path '/' dataset '_data/app_based_results/app_based_results_manual.mat']);
        else
            [shape_diff, app_diff_avg, app_diff_min] = get_app_measure(path, all_face_list, dataset, 0);
        end
        for i=1:size(err_thresh,1)
            thresh = err_thresh(i);
            [chehra_accuracy, deva_accuracy, intraface_accuracy, rcpr_accuracy, our_model_accuracy] = get_model_accuracies(path, face_list, dataset, thresh, 0);
            manual_results(i,:) = [chehra_accuracy, deva_accuracy, intraface_accuracy, rcpr_accuracy, our_model_accuracy];
        end
    end
    
end

