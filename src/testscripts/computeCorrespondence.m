clear all ; close all ;

% First pick 500 random points from the database.
nrandpts = 500 ;
pt_indx = randperm(4735) ;
pt_indx = pt_indx(1:500) ;

% PATH LOADING: Change these lines before running!
load('~/FaceAnimation/JNData/Faces5000/intermediate_results/bounding_boxes.mat') ;
load('~/FaceAnimation/JNData/Faces5000/intermediate_results/face_map.mat') ;
load('~/FaceAnimation/src/feature_representation/featureVector_edgeWeight_extraction/face_p99.mat') ;

% Variables bounding_boxes and mapping need to be used, if necessary.
% Initially set all distances to infinity.
dist_adjacency = Inf*ones( nrandpts, nrandpts ) ;

% Now for each pair, build the shape distance matrix.
% One check if distance metric is good is to see that its symmetric.
% Once metric is computed we can check this.
cntr = 1 ;
tic ;
cx1 = zeros(99, 1) ;
cx2 = zeros(99, 1) ;
cy1 = zeros(99, 1) ;
cy2 = zeros(99, 1) ;
mc = model.components ;
for i = 1 : nrandpts
	for j = 1 : nrandpts
		if i == j
			continue ;
		end
		if toc > 10
			fprintf( 'Processing points (%d/%d, %d/%d)\n', i, nrandpts, j, nrandpts ) ;
			tic ;
		end

		% First take the images of the correct index.
		k = pt_indx(i) ;
		l = pt_indx(j) ;

		% If they are empty (some cases found in bounding_boxes, do nothing.
		if isempty(bounding_boxes{k})
			continue ;
		end
		if isempty(bounding_boxes{l})
			continue ;
		end

		cx1(:) = 0; cy1(:) = 0; cx2(:) = 0; cy2(:) = 0 ;

		% Now note down the indices that map all points in the 'xy' variable
		% in bounding_boxes to their actual respective locations.
		idxk = [mc{bounding_boxes{k}.c}.filterid]' ;
		idxl = [mc{bounding_boxes{l}.c}.filterid]' ;

		% Computing centres of each part bbox. These form the locations of each
		% fiducial marker.
		cx1(idxk) = bounding_boxes{k}.xy(:,1) + bounding_boxes{k}.xy(:,3) ;
		cy1(idxk) = bounding_boxes{k}.xy(:,2) + bounding_boxes{k}.xy(:,4) ;

		cx2(idxl) = bounding_boxes{l}.xy(:,1) + bounding_boxes{l}.xy(:,3) ;
		cy2(idxl) = bounding_boxes{l}.xy(:,2) + bounding_boxes{l}.xy(:,4) ;
		cx1 = cx1 / 2; cy1 = cy1 / 2; cx2 = cx2 / 2; cy2 = cy2 / 2 ;

		% Now compute minimal translation that will align the two shapes in the same coordinate
		% system. Don't unnecessarily penalize for points that are not present.
		cx1 = cx1 - mean(cx1(idxk)) ;
		cy1 = cy1 - mean(cy1(idxk)) ;
		cx2 = cx2 - mean(cx2(idxl)) ;
		cy2 = cy2 - mean(cy2(idxl)) ;

		% Now compute minimal scale that aligns the two shapes to the same scale.
		s = sum( cx1.*cx2 + cy1.*cy2 ) ./ sum( cx1.^2 + cy1.^2 ) ;

		cx1 = cx1 * s ;
		cy1 = cy1 * s ;

		idcommon = intersect(idxk, idxl) ;
		% Now compute the euclidean distance and store it in adjacency matrix.
		distval = sqrt( sum( (cx1(idcommon)-cx2(idcommon)).^2 + (cy1(idcommon)-cy2(idcommon)).^2 ) ) / length(idcommon) ;
		dist_adjacency(i, j) = distval ;

		% save the transformed points somewhere so that we can later verify the
		% transformation.
		tmpbbox(cntr).bbox1 = [cx1 cy1] ;
		tmpbbox(cntr).bbox = [cx2 cy2] ;
		tmpbbox(cntr).ids = [k l] ;

		% Finally do the required increment to counter.
		cntr = cntr + 1 ;
	end
end

% Check if the metric is symmetric.
if abs(sum(sum(dist_adjacency - dist_adjacency'))) < 1e-3
	disp('Distance seems to be symmetric in nature!') ;
end
