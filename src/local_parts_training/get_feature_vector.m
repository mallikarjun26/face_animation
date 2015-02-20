function feature_vector = get_feature_vector(part_patches)

    %
    number_of_parts = size(part_patches,1);
    feature_vector  = cell(number_of_parts,1);
    FEATURE_VECTOR_SIZE = 100;
    
    %
    for i=1:number_of_parts
       
        samples = part_patches{i,1};
        number_of_samples = size(samples);
        part_feat = zeros(number_of_samples, FEATURE_VECTOR_SIZE);
        
        for j=1:number_of_samples
            
            im = samples{j,1};
           
            if(isempty(im))
               temp_feat = NaN * ones(1, FEATURE_VECTOR_SIZE); 
               part_feat(j,:) = temp_feat;
               continue;
            end
            
            temp_feat = vl_dsift(im);
            part_feat(j,:) = temp_feat;
            
        end
        
    end
    
end