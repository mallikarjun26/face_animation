function part_locations = get_part_locations(local_prob, part_dist_of_exemplars)

    %
    
    %
    number_of_exemplars = size(part_dist_of_exemplars, 1);
    number_of_parts     = size(local_prob, 1);
    image_size = size(local_prob{1});
    part_locations = zeros(number_of_parts, 2);
    
    %
    for ii=1:number_of_parts
        posterior_prob = double(zeros(image_size));
        current_part   = local_prob{ii};
        for i=1:image_size(1,1)
            for j=1:image_size(1,2)
                for k=1:number_of_exemplars

                    part_dist = part_dist_of_exemplars{k};
                    
                    y0 = part_dist(ii, 1);
                    x0 = part_dist(ii, 2);
                    sigma_y = part_dist(ii, 3);
                    sigma_x = part_dist(ii, 4);
                    
                    cond_prob = exp(- ( (double((i - y0)^2) / sigma_y ) + (double((j - x0)^2) / sigma_x) ) );
                    posterior_prob(i,j) = posterior_prob(i,j) + (current_part(i,j) * cond_prob);

                end
            end
        end
        
        %disp(['Done finding part ' num2str(ii) '/' num2str(number_of_parts) ' location']);
        [value index] = max(posterior_prob(:));
        [a b] = ind2sub(image_size, index);
        part_locations(ii, :) = [a b];
    end
     
end