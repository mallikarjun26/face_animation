function alignment_main(im, path)

    %
    load([path '/intermediate_results/local_filters.mat']);
    load([path '/intermediate_results/global_fiducials.mat']);
    addpath('./utils/');
    
    %
    image_size = [250 250];
    im = imresize(im, image_size);
    
    %
    disp('Finding probablities based on local detector output ....');
    local_prob = get_part_probability(im, local_filters);
    
    %
    disp('Choosing (k,t) feasible sets ....');
    feasible_global_models = choose_global_models(global_fiducials, local_prob, image_size);

    %
    disp('Finding part distributions for selected global models ....')
    part_dist_of_exemplars = get_part_dist_of_exemplars(feasible_global_models);
    
    %
    disp('Aligning the part locations based on informations calculated ....');
    part_locations = get_part_locations(local_prob, part_dist_of_exemplars);
    
    %
    disp('Displaying aligned face locations');
    plot_fiducials(im, part_locations);
    
end