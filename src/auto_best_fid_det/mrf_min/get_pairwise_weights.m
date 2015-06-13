function pairwise_weights = get_pairwise_weights(dataset, part_near_exemplar)

    load(['~/Documents/data/iccv/' dataset '_data/sim_image_list_kmeans_shape_en_20_exemplars.mat']); 
    load(['~/Documents/data/iccv/' dataset '_data/ground_truth.mat']); 

    %%

    labels = 21;
    nodes = 80;
    pairwise_weights = zeros(3040, 1);

    %%
    count = 1;
    for pix1=1:nodes
        for pix2=pix1:nodes
            
            method1 = ceil(pix1/20);
            method2 = ceil(pix2/20);
            part1 = mod(pix1-1,20) + 1;
            part2 = mod(pix2-1,20) + 1;

            if(part1 ~= part2)
                exem1 = part_near_exemplar(method1, part1);
                exem2 = part_near_exemplar(method2, part2);

                pose1 = ground_truth{exem1};
                pose2 = ground_truth{exem2};

                pairwise_weights(count) = get_pose_diff(pose1, pose2);
                count = count + 1;
            end
        end
    end

    %non_zeros = find(pairwise_weights(:));
    
    %pairwise_weights = ( pairwise_weights - min(pairwise_weights(non_zeros)) ) / range(pairwise_weights(non_zeros));
    pairwise_weights = ( pairwise_weights - min(pairwise_weights(:)) ) / range(pairwise_weights(:));
    
end

function pairwise_weight = get_pose_diff(pose1, pose2)

    %%
    pose1(:,1) = pose1(:,1) - mean(pose1(:,1));
    pose1(:,2) = pose1(:,2) - mean(pose1(:,2));
    pose2(:,1) = pose2(:,1) - mean(pose2(:,1));
    pose2(:,2) = pose2(:,2) - mean(pose2(:,2));

    s = sum( pose1(:,1).*pose2(:,1) + pose1(:,2).*pose2(:,2) ) ./ sum( pose1(:,1).^2 + pose1(:,2).^2 );

    pose1(:,1) = pose1(:,1) * s;
    pose1(:,2) = pose1(:,2) * s;


    pose1 = pose1(:)';
    pose2 = pose2(:)';

    pairwise_weight = pdist(double([pose1; pose2]));

end
