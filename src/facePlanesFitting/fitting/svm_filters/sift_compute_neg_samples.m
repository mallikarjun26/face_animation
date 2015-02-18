function sift_data_neg = sift_compute_neg_samples( fids, f_sc_one, f_sc_two, d_sc_one, d_sc_two, io_dist, face_roi, num_samples )
% function sift_data_neg = sift_compute_neg_samples( fids, f_sc_one, f_sc_two, d_sc_one, d_sc_two, io_dist, face_roi, num_samples )

% Algorithm for negative sample generation.
% - For every fiducial point
% -		Take a random sample at a distance of > 1/4 interocular distance (io_dist(1))
% -		Concatenate sift descriptors at both scales to negative sample.
% -	End

% Initializing negative data sample matrix.
sift_data_neg		=	[];
num_fiducials		=	size( fids, 1 );
dist_img			=	zeros( face_roi(4), face_roi(3) );

for i = 1 : num_fiducials
	% First take fiducial locations.
	x 							=	fids(i, 1);
	y 							=	fids(i, 2);
	cntr						=	0;
	dist_img(:)					=	0;
	dist_img( y-face_roi(2), ...
			x-face_roi(1) )		=	1 ;
	dist_img					=	bwdist( dist_img );			% Compute distance transform.

	% For each random sample that you generate
	while cntr < num_samples
		x_rand	=	randi( face_roi(3), 1, 1 );
		y_rand	=	randi( face_roi(4), 1, 1 );

		% If it has an interocular distance > io_dist
		if dist_img( y_rand-1, x_rand-1 ) > io_dist

			% Collect the indexes of features on both scales, 
			% and concatenate them to form the negative example to
			% add to sift_data_neg
			idx_one				=	find( ( f_sc_one(1, :) == (x_rand+face_roi(1)) ) ...
										& ( f_sc_one(2, :) == (y_rand+face_roi(2)) ) );
			idx_two				=	find( ( f_sc_two(1, :) == (x_rand+face_roi(1)) ) ...
										& ( f_sc_two(2, :) == (y_rand+face_roi(2)) ) );

            sift_data_neg		=	[ sift_data_neg, [d_sc_one(:, idx); d_sc_two(:, idx)] ];
			cntr 				=	cntr + 1;
		end
	end
end

