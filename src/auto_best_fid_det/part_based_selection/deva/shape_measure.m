function shape_appearance(input_path)

    %
    load('face_p99.mat') ;
    load([input_path '/intermediate_results/facemap.mat']);
    load([input_path '/intermediate_results/bounding_boxes.mat']);
    
    %
    number_of_nodes     = size(facemap, 2);
    shape_graph         = Inf * ones(number_of_nodes, number_of_nodes);
    mc                  = model.components ;
    
    %
    cx1 = zeros(99, 1) ;
    cx2 = zeros(99, 1) ;
    cy1 = zeros(99, 1) ;
    cy2 = zeros(99, 1) ;
    
    tic;
    %
    for i = 1 : number_of_nodes
    	for j = i : number_of_nodes
            
            if i == j
                continue ;
            end
            
            if toc > 10
                fprintf( 'Processing points (%d/%d, %d/%d)\n', i, number_of_nodes, j, number_of_nodes) ;
                tic ;
            end

            % If they are empty (some cases found in bounding_boxes, do nothing.
            if isempty(bounding_boxes{i})
                continue ;
            end
            if isempty(bounding_boxes{j})
                continue ;
            end

            cx1(:) = 0; cy1(:) = 0; cx2(:) = 0; cy2(:) = 0 ;

            % Now note down the indices that map all points in the 'xy' variable
            % in bounding_boxes to their actual respective locations.
            id_1 = [mc{bounding_boxes{i}.c}.filterid]' ;
            id_2 = [mc{bounding_boxes{j}.c}.filterid]' ;

            % Computing centres of each part bbox. These form the locations of each
            % fiducial marker.
            cx1(id_1) = bounding_boxes{i}.xy(:,1) + bounding_boxes{i}.xy(:,3) ;
            cy1(id_1) = bounding_boxes{i}.xy(:,2) + bounding_boxes{i}.xy(:,4) ;

            cx2(id_2) = bounding_boxes{j}.xy(:,1) + bounding_boxes{j}.xy(:,3) ;
            cy2(id_2) = bounding_boxes{j}.xy(:,2) + bounding_boxes{j}.xy(:,4) ;
            cx1 = cx1 / 2; cy1 = cy1 / 2; cx2 = cx2 / 2; cy2 = cy2 / 2 ;

            % Now compute minimal translation that will align the two shapes in the same coordinate
            % system. Don't unnecessarily penalize for points that are not present.
            cx1 = cx1 - mean(cx1(id_1)) ;
            cy1 = cy1 - mean(cy1(id_1)) ;
            cx2 = cx2 - mean(cx2(id_2)) ;
            cy2 = cy2 - mean(cy2(id_2)) ;

            % Now compute minimal scale that aligns the two shapes to the same scale.
            s = sum( cx1.*cx2 + cy1.*cy2 ) ./ sum( cx1.^2 + cy1.^2 ) ;

            cx1 = cx1 * s ;
            cy1 = cy1 * s ;

            idcommon = intersect(id_1, id_2) ;
            % Now compute the euclidean distance and store it in adjacency matrix.
            distval = sqrt( sum( (cx1(idcommon)-cx2(idcommon)).^2 + (cy1(idcommon)-cy2(idcommon)).^2 ) ) / length(idcommon) ;
            shape_graph(i, j) = distval ;
            shape_graph(j, i) = distval ;

            % save the transformed points somewhere so that we can later verify the
            % transformation.
            % tmpbbox(cntr).bbox1 = [cx1 cy1] ;
            % tmpbbox(cntr).bbox = [cx2 cy2] ;
            % tmpbbox(cntr).ids = [k l] ;

            % Finally do the required increment to counter.
            % cntr = cntr + 1 ;
        end
    end

    %
    save([input_path '/intermediate_results/shape_graph.mat'], 'shape_graph');
    
end