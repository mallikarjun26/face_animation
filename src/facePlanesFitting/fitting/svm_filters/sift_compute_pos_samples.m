function sift_data_pos = sift_compute_pos_samples( fids, f_sc_one, f_sc_two, d_sc_one, d_sc_two )
% function sift_data_pos = sift_compute_pos_samples( fids, f_sc_one, f_sc_two, d_sc_one, d_sc_two )
% Computes positive data samples at the exact locations of fiducials once image and corresponding
% sift features are computed.

sift_data_pos		=	[];

for i = 1 : num_fiducials
	x				=	fids(i, 1);
	y				=	fids(i, 2);

	% Find the location of this fidiucial in the two sets of descriptors.
	idx_one			=	find( (f_sc_one(1, :) == x) & (f_sc_one(2, :) == y) );
	idx_two			=	find( (f_sc_two(1, :) == x) & (f_sc_two(2, :) == y) ); 

	% Concatenate them to get the feature vector desired.
	sift_data_pos	=	[sift_data_pos [d_sc_one(:, idx_one); d_sc_two(:, idx_two)];
end
