function pose_distribution(path)
    
    %
    clc;

    %
    load([path '/intraface_data/intermediate_results/intraface_fids.mat']);
    load([path '/Faces5000/intermediate_results/facemap.mat']);
    load([path '/common_data/452_analysis/cdir_ground_truth.mat']);
    
    %
    number_of_clusters = 10;
    intraface_failures = find(cdir_ground_truth(:,4) == 0);
    intraface_failures = cdir_ground_truth(intraface_failures, 1);
    intraface_successes = [1:size(facemap,2)]';
    intraface_successes = setdiff(intraface_successes, intraface_failures);
    number_of_samples = size(intraface_successes,1);
    feature_dimension = size(intraface_fids{1},1) * 2;
    feature_vector = zeros(feature_dimension, number_of_samples);
    fid_s = int16(intraface_fids{2});
    
    %
    for i=1:number_of_samples
        index = intraface_successes(i);
        fid_t = int16(intraface_fids{index});
        feature_vector(:, i) = get_normalized_feature_vector(fid_t, fid_s);
    end
    
    %
    
    [centers, assignments] = vl_kmeans(feature_vector, number_of_clusters);
    
    plot_hist(centers, assignments);
    plot_poses(centers, assignments);
    
end

function plot_hist(centers, assignments)

    figure;
    a = double(assignments);
    hist(a);
    xlabel('poses');
    ylabel('number of samples');
    
end

function plot_poses(centers, assignments)

    %
    number_of_poses = size(centers, 2);
    figure;

    %
    for i=1:number_of_poses
        subplot(2,5,i);
        plot(centers(50:98, i), centers(1:49, i), 'b.');
    end

end

function feat_vect =get_normalized_feature_vector(fid_t, fid_s)

    % Now compute minimal translation that will align the two shapes in the same coordinate
    % system. Don't unnecessarily penalize for points that are not present.
    fid_t(:,1) = fid_t(:,1) - mean(fid_t(:,1));
    fid_t(:,2) = fid_t(:,2) - mean(fid_t(:,2));
    
    fid_s(:,1) = fid_s(:,1) - mean(fid_s(:,1));
    fid_s(:,2) = fid_s(:,2) - mean(fid_s(:,2));
    
    % Now compute minimal scale that aligns the two shapes to the same scale.
    s = sum( fid_t(:,1).*fid_s(:,1)  +  fid_t(:,2).*fid_s(:,2)  )  ./  sum( fid_t(:,1).^2 + fid_t(:,2).^2 ); 
    
    fid_t(:,1) = fid_t(:,1) * s;
    fid_t(:,2) = fid_t(:,2) * s;
    
    feat_vect = [fid_t(:,1)' fid_t(:,2)'];
    
end