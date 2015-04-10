function [xTr, yTr, xTe, yTe] =  get_data(path, dataset, part_number)

    %
    load([path '/' dataset '_data/app_based_results/ground_truth_app_vector.mat']);
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);

    %
    if(dataset == 'lfpw')
        test_list = [201:300]';
        train_list = [1:200]';
%        test_list = [812:1035]';
%        train_list = [1:811]';
        common_fid_index = 7; 
    elseif(dataset == 'cofw')
        test_list = [201:300]';
        train_list = [1:200]';
%         test_list = [1346:1852]';
%         train_list = [1:1345]';
        common_fid_index = 8; 
    elseif(dataset == 'aflw')
        test_list = [5251:5375]';
        train_list = [5000:5250]'; 
        common_fid_index = 9; 
    end
    
    %
    feature_dimension = size(ground_truth_app_vector{1}{1}, 2);
    test_samples  = size(test_list, 1)  * 20; 
    train_samples = size(train_list, 1) * 20; 

    % xTr = zeros(feature_dimension, train_samples);
    % yTr = zeros(1, train_samples);
    % xTe = zeros(feature_dimension, test_samples);
    % yTe = zeros(1, test_samples);
    xTr = []; 
    yTr = []; 
    xTe = []; 
    yTe = []; 

    %
    number_of_classes = size(ground_truth_app_vector{1},1);
    class_index = chehra_deva_intraface_rcpr_common_fids(:,common_fid_index);
    for i=1:size(train_list, 1)
        index = train_list(i);
        sample = ground_truth_app_vector{index};
        
        for j=1:number_of_classes
            sample_part = sample{j}';

            if(~isnan(sample_part(1)))
                xTr = [xTr sample_part];
                if(part_number == j)
                    yTr = [yTr 1];
                else
                    yTr = [yTr 0];
                end

            end

        end 

    end
    for i=1:size(test_list, 1)
        index = test_list(i);
        sample = ground_truth_app_vector{index};
        
        for j=1:number_of_classes
            sample_part = sample{j}';
            if(~isnan(sample_part(1)))
                xTe = [xTe sample_part];
                if(part_number == j)
                    yTe = [yTe 1];
                else
                    yTe = [yTe 0];
                end

            end

        end 

    end
    
    xTr = double(xTr);
    yTr = double(yTr);
    xTe = double(xTe);
    yTe = double(yTe);

end
