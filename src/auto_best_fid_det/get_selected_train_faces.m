function get_selected_train_faces(path, dataset)

    %
    run('~/src/vlfeat/vlfeat-0.9.19/toolbox/vl_setup');

    %
    NUMCENTERS = 11;
    if(dataset=='aflw')
        load([path '/' dataset '_data/ground_truth_smith.mat']);
    else
        load([path '/' dataset '_data/ground_truth.mat']);
    end

    %
    [X, mod_to_ori_map] = get_X(ground_truth, dataset);
    [C, A] = vl_kmeans(X, NUMCENTERS);

    %
    sim_list = get_subset(C, A, X, NUMCENTERS, mod_to_ori_map);    

    %
    save([path '/' dataset '_data/sim_image_list.mat'], 'sim_list');
end

function sim_list = get_subset(C, A, X, NUMCENTERS, mod_to_ori_map)

    sim_list = zeros(NUMCENTERS, 1);
    sample_num = cell(NUMCENTERS,1);
    
    for i=1:NUMCENTERS
        a = find(A==i);
        sample_num{i,1} = a;
    end 

    for i=1:NUMCENTERS
        list = sample_num{i};
        num_samples_each = size(list,2);    
        center_sample = C(:,i);
        min_dist = realmax;
        for j=1:num_samples_each
            sim_list_t = list(j);
            temp = [center_sample' ; X(:,sim_list_t)' ];     
            dist_t = pdist(temp);

            if(dist_t < min_dist)
                min_dist = dist_t;
                sim_list(i) = sim_list_t;
            end 
        end
    end

    for i=1:NUMCENTERS
        sim_list(i) = mod_to_ori_map(sim_list(i));
    end
    
end


function [X, mod_to_ori_map] = get_X(ground_truth, dataset)

    %
    if(dataset == 'lfpw')
        number_of_training_samples = 811; 
        number_of_fids = 68;
    elseif(dataset == 'cofw')
        number_of_training_samples = 1345;
        number_of_fids = 29;
    elseif(dataset == 'aflw')
        number_of_training_samples = 18000;
        number_of_fids = 85;
    end

    %X = zeros(number_of_fids*2, number_of_training_samples);
    X = [];
    mod_to_ori_map = [];
    for i=1:number_of_training_samples;
        fid = ground_truth{i};
        if(isempty(fid))
            continue;
        end
        %X(:,i) = [fid(:,1); fid(:,2)];
        mod_to_ori_map = [mod_to_ori_map ; i];
        X = [X [fid(:,1); fid(:,2)]];
    end

end
