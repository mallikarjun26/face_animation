function [out_resp] = merge_resp(our_resp, hog_resp)

    num_of_fil_resp = size(our_resp, 2);
    out_resp = cell(1, num_of_fil_resp);
    for k=1:num_of_fil_resp
        
        our_resp_p = our_resp{k};

        if(isempty(our_resp_p))    
            hog_resp_p = hog_resp{k};
            range_t = range(hog_resp_p(:));
            min_t   = min(hog_resp_p(:));
            hog_resp_p = (hog_resp_p - min_t) / range_t;
            out_resp{k} = hog_resp_p;
        else
            hog_resp_p = hog_resp{k};
            range_t = range(hog_resp_p(:));
            min_t   = min(hog_resp_p(:));
            hog_resp_p = (hog_resp_p - min_t) / range_t;
            
            alpha = get_alpha(our_resp_p);
            
            out_resp{k} = (alpha .* our_resp_p) + ((1-alpha) .* hog_resp_p);
        end
        
    end
    
end

function alpha = get_alpha(our_resp_p)

    max_resp = max(our_resp_p(:));
    min_resp = min(our_resp_p(:));
    
    scale = exp(- min_resp^2 / (2*max_resp^2) );

    alpha = 1 - ( (1/scale) * exp( - our_resp_p.^2 / (2 * max_resp^2) ) );
    
end
