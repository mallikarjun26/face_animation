function alignment_main(im, path, only_tr_sc)

    clc;

    %
    load([path '/intermediate_results/local_filters.mat']);
    load([path '/intermediate_results/global_fiducials.mat']);
    addpath('./utils/');
    image_size = size(im);
    
    %
    disp('Finding probablities based on local detector output ....');
    local_prob = get_part_probability(im, local_filters, path);
    filtered_size = size(local_prob{1});
    worn_out_size = (image_size(1,1) - filtered_size(1,1))/2;
    y1 = worn_out_size + 1;
    y2 = image_size(1,1) - worn_out_size ;
    x1 = worn_out_size + 1;
    x2 = image_size(1,2) - worn_out_size ;
    
    im = im( y1:y2, x1:x2, :);
    
    %
    tic;
    disp('Choosing (k,t) feasible sets ....');
%     if(exist([path '/intermediate_results/feasible_global_models.mat']) > 0)
%         disp('Loading from previously stored results');
%         load([path '/intermediate_results/feasible_global_models.mat']);
%     else
         feasible_global_models = choose_global_models(global_fiducials, local_prob, filtered_size, im, path, only_tr_sc);
%         save([path '/intermediate_results/feasible_global_models.mat'], 'feasible_global_models');
%     end
    
    disp(['Time taken = ' num2str(toc)]);
    
    
    %
    tic;
    disp('Finding part distributions for selected global models ....')
    part_dist_of_exemplars = get_part_dist_of_exemplars(feasible_global_models);
    disp(['Time taken = ' num2str(toc)]);
    
    %
    tic;
    disp('Aligning the part locations based on informations calculated ....');
    part_locations = get_part_locations(local_prob, part_dist_of_exemplars);
    disp(['Time taken = ' num2str(toc)]);
    
    %
    disp('Displaying aligned face locations');
    plot_fiducials(im, part_locations);
    
end