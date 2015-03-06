function [shape_chehra_deva, shape_chehra_rcpr, shape_deva_rcpr, shape_chehra_intraface, shape_deva_intraface, shape_intraface_rcpr] = get_shape_measure_histogram(path)

    %
    clc;

    %
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
    load([path '/chehra_data/intermediate_results/chehra_fids.mat']);
    load([path '/deva_data/intermediate_results/deva_fids.mat']);
    load([path '/intraface_data/intermediate_results/intraface_fids.mat']);
    load([path '/rcpr_data/intermediate_results/rcpr_fids.mat']);
    load([path '/Faces5000/intermediate_results/facemap.mat']);

    %
    number_of_faces = size(facemap,2);
    shape_chehra_deva      = zeros(number_of_faces,1);     
    shape_chehra_rcpr      = zeros(number_of_faces,1);    
    shape_deva_rcpr        = zeros(number_of_faces,1);   
    shape_chehra_intraface = zeros(number_of_faces,1);   
    shape_deva_intraface   = zeros(number_of_faces,1);    
    shape_intraface_rcpr   = zeros(number_of_faces,1);    
    
    tic;
    for i=1:number_of_faces

        if(mod(i,200)==0)
            %disp([num2str(i) '/' num2str(number_of_faces) ' running']);
        end
        
        s_chehra_fid    = chehra_fids{i};
        s_deva_fid      = deva_fids{i};
        s_rcpr_fid      = rcpr_fids{i};
        s_intraface_fid      = intraface_fids{i};

        %
        if(isempty(s_deva_fid))
            s_deva_fid.xy = NaN * ones(68,4);
        elseif(size(s_deva_fid.xy,1) ~=68)    % Neglecting profile poses of Deva, as it is consistently doing bad compared to others.
            s_deva_fid.xy = NaN * ones(68,4);
        end
        if(isempty(s_intraface_fid))
            s_intraface_fid = NaN * ones(49,2);
        end
        if(isempty(s_rcpr_fid))
            s_rcpr_fid = NaN * ones(29,2);
        end
        if(isempty(s_chehra_fid))
            s_chehra_fid = NaN * ones(49,2);
        end
        
        %
        [shape_chehra_deva_t, shape_chehra_rcpr_t, shape_deva_rcpr_t, shape_chehra_intraface_t, shape_deva_intraface_t, shape_intraface_rcpr_t] = get_shape_similarity(s_chehra_fid, s_deva_fid, s_intraface_fid, s_rcpr_fid, chehra_deva_intraface_rcpr_common_fids);

        shape_chehra_deva(i,1)      = shape_chehra_deva_t     ;     
        shape_chehra_rcpr(i,1)      = shape_chehra_rcpr_t     ;    
        shape_deva_rcpr(i,1)        = shape_deva_rcpr_t       ;   
        shape_chehra_intraface(i,1) = shape_chehra_intraface_t;   
        shape_deva_intraface(i,1)   = shape_deva_intraface_t  ;    
        shape_intraface_rcpr(i,1)   = shape_intraface_rcpr_t  ;    

    end
    disp(['Time taken: ' num2str(toc)]);
    
    save([path '/common_data/shape_comp_histograms/shape_comp_results.mat'], 'shape_chehra_deva', 'shape_chehra_rcpr', 'shape_deva_rcpr', 'shape_chehra_intraface', 'shape_deva_intraface', 'shape_intraface_rcpr');

    h1 = figure; hist( shape_chehra_deva, 50      ); title( 'shape chehra deva'      );
    saveas(h1, [path '/common_data/shape_comp_histograms/shape_chehra_deva.jpg']);
    h2 = figure; hist( shape_chehra_rcpr, 50      ); title( 'shape chehra rcpr'      );
    saveas(h2, [path '/common_data/shape_comp_histograms/shape_chehra_rcpr.jpg']);
    h3 = figure; hist( shape_deva_rcpr, 50        ); title( 'shape deva rcpr'        );
    saveas(h3, [path '/common_data/shape_comp_histograms/shape_deva_rcpr.jpg']);
    h4 = figure; hist( shape_chehra_intraface, 50 ); title( 'shape chehra intraface' );
    saveas(h4, [path '/common_data/shape_comp_histograms/shape_chehra_intraface.jpg']);
    h5 = figure; hist( shape_deva_intraface, 50   ); title( 'shape deva intraface'   );
    saveas(h5, [path '/common_data/shape_comp_histograms/shape_deva_intraface.jpg']);
    h6 = figure; hist( shape_intraface_rcpr, 50   ); title( 'shape intraface rcpr'   );
    saveas(h6, [path '/common_data/shape_comp_histograms/shape_intraface_rcpr.jpg']);

end

function [shape_chehra_deva, shape_chehra_rcpr, shape_deva_rcpr, shape_chehra_intraface, shape_deva_intraface, shape_intraface_rcpr] = get_shape_similarity(s_chehra_fid, s_deva_fid, s_intraface_fid, s_rcpr_fid, chehra_deva_intraface_rcpr_common_fids)

    % TODO: Make it scale and translation invariant    

    %
    number_of_common_parts = size(chehra_deva_intraface_rcpr_common_fids,1);

    t1 = double([ s_chehra_fid(chehra_deva_intraface_rcpr_common_fids(:,1),1)' s_chehra_fid(chehra_deva_intraface_rcpr_common_fids(:,1),2)' ]);
    x = (s_deva_fid.xy(:,1) + s_deva_fid.xy(:,3) ) / 2 ;
    y = (s_deva_fid.xy(:,2) + s_deva_fid.xy(:,4) ) / 2 ;
    t2 = double([y(chehra_deva_intraface_rcpr_common_fids(:,2),1)' x(chehra_deva_intraface_rcpr_common_fids(:,2),1)' ]);
    t3 = double([ s_intraface_fid(chehra_deva_intraface_rcpr_common_fids(:,3),1)' s_intraface_fid(chehra_deva_intraface_rcpr_common_fids(:,3),2)' ]);
    t4 = double([ s_rcpr_fid(chehra_deva_intraface_rcpr_common_fids(:,4),1)' s_rcpr_fid(chehra_deva_intraface_rcpr_common_fids(:,4),2)' ]);
    
    
    t = [t1 ; t2];
    shape_chehra_deva = pdist(t) / number_of_common_parts;
    
    t = [t1 ; t4];
    shape_chehra_rcpr = pdist(t) / number_of_common_parts;
    
    t = [t2 ; t4];
    shape_deva_rcpr = pdist(t) / number_of_common_parts;

    t = [t1 ; t3];
    shape_chehra_intraface = pdist(t) / number_of_common_parts;

    t = [t2 ; t3];
    shape_deva_intraface = pdist(t) / number_of_common_parts;

    t = [t3 ; t4];
    shape_intraface_rcpr = pdist(t) / number_of_common_parts;
    
end
