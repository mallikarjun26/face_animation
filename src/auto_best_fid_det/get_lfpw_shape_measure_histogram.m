function [shape_chehra_intraface] = get_lfpw_shape_measure_histogram(path)

    %
    clc;

    %
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
    load([path '/lfpw_data/facemap.mat']);
    load([path '/lfpw_data/chehra_fids.mat']);
    load([path '/lfpw_data/intraface_fids.mat']);
    
    %
    number_of_faces = size(facemap,2);
    shape_chehra_intraface = zeros(number_of_faces,1);   
    
    tic;
    for i=1:number_of_faces

        if(mod(i,200)==0)
            %disp([num2str(i) '/' num2str(number_of_faces) ' running']);
        end
        
        s_chehra_fid    = chehra_fids{i};
        s_intraface_fid      = intraface_fids{i};

        %
        if(isempty(s_intraface_fid))
            s_intraface_fid = NaN * ones(49,2);
        end
        
        if(isempty(s_chehra_fid))
            s_chehra_fid = NaN * ones(49,2);
        end
        
        %
        [shape_chehra_intraface_t] = get_shape_similarity(s_chehra_fid, s_intraface_fid, chehra_deva_intraface_rcpr_common_fids);

        shape_chehra_intraface(i,1) = shape_chehra_intraface_t;   
        
    end
    disp(['Time taken: ' num2str(toc)]);
    
    save([path '/lfpw_data/shape_comp_histograms/shape_comp_results.mat'], 'shape_chehra_intraface');

    h4 = figure; hist( shape_chehra_intraface, 50 ); title( 'shape chehra intraface' );
    saveas(h4, [path '/lfpw_data/shape_comp_histograms/shape_chehra_intraface.jpg']);

end

function [shape_chehra_intraface] = get_shape_similarity(s_chehra_fid, s_intraface_fid, chehra_deva_intraface_rcpr_common_fids)

    % TODO: Make it scale and translation invariant    

    %
    number_of_common_parts = size(chehra_deva_intraface_rcpr_common_fids,1);

    t1 = double([ s_chehra_fid(chehra_deva_intraface_rcpr_common_fids(:,1),1)' s_chehra_fid(chehra_deva_intraface_rcpr_common_fids(:,1),2)' ]);
    t3 = double([ s_intraface_fid(chehra_deva_intraface_rcpr_common_fids(:,3),1)' s_intraface_fid(chehra_deva_intraface_rcpr_common_fids(:,3),2)' ]);
    
    t = [t1 ; t3];
    shape_chehra_intraface = pdist(t) / number_of_common_parts;

end
