function part_locations = get_part_locations(local_prob, part_dist_of_exemplars)

    %
    
    %
    number_of_exemplars = size(part_dist_of_exemplars, 1);
    number_of_parts     = size(local_prob, 1);
    image_size = size(local_prob);
    part_locations = zeros(number_of_parts, 2);
    
    %
    for ii=1:number_of_parts
        posterior_prob = zeros(image_size);
        current_part   = local_prob{ii};
        for i=1:image_size(1,1)
            for j=1:image_size(1,2)
                for k=1:number_of_exemplars

                    part_dist = part_dist_of_exemplars{k};
                    
                    x0 = part_dist(ii, 1);
                    y0 = part_dist(ii, 2);
                    sigma_x = part_dist(ii, 3);
                    sigma_y = part_dist(ii, 4);
                    
                    cond_prob = exp(- ( ((i - x0)^2 / sigma_x ) + ((j - y0)^2 / sigma_y) ) );
                    posterior_prob(i,j) = posterior_prob(i,j) + (current_part(i,j) * cond_prob);

                end
            end
        end
        
        [value index] = max(posterior_prob(:));
        part_locations = ind2sub(image_size, index);
        
    end
    
end