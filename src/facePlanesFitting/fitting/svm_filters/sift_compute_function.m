function [sift_data, example_sign] = sift_compute_function( imstruct, fids, sift_params )
% function [sift_data, example_sign] = sift_compute_function( imstruct, fids, sift_params )

if( size(fids, 1) < size(fids, 2) )
	fids = fids';
end

num_fiducials 			=	size(fids, 1);
sift_data				=	[];
example_sign    		=	[];

% Assuming that there is a 20% border around the face detector, and that 50% of
% the detected face area is occupied by the eyes.
scale_one				=	0.1 * ( imstruct.roi(3) - imstruct.roi(1) ); 		% 1/4 th interocular distance.
scale_two				=	0.2 * ( imstruct.roi(3) - imstruct.roi(1) ); 		% 1/2 th interocular distance.

img_gray				=	single( rgb2gray(imstruct.img) );
[f_sc_one, d_sc_one]	=	vl_dsift( img_gray, 'size', scale_one );
[f_sc_two, d_sc_two]	=	vl_dsift( img_gray, 'size', scale_two );

% Fiducial locations are computed with reference to the face detector.
% But sift descriptors are computed on the entire image, so to get the
% correct fiducial locations, we need to add the roi. Finally round
% them to integers.
fids(:, 1)				=	round( fids(:, 1) + imstruct.roi(2) );
fids(:, 2)				=	round( fids(:, 2) + imstruct.roi(1) );

% First compute positive samples.
sift_data_pos			=	sift_compute_pos_samples( fids, f_sc_one, f_sc_two, d_sc_one, ...
								d_sc_two );

% Now compute negative samples at 1/4 interocular distance away.
sift_data_neg			=	sift_compute_neg_samples( fids, f_sc_one, f_sc_two, d_sc_one, ...
								d_sc_two, scale_one, imstruct.roi, sift_params.neg_samples );

% Now flip the images and compute the same.
fprintf( 'Now Flipping Images to compute Positive / Negative Samples\n' );

img_gray_lr_flip		=	img_gray(:, end:-1:1);								% Left-Right Flip
fids_lr_flip			=	[ size(img_gray, 2)-fids(:, 1) fids(:, 2) ];
img_gray_td_flip		=	img_gray(end:-1:1, :);								% Top-Down Flip
fids_td_flip			=	[ fids(:, 1) size(img_gray, 1)-fids(:, 2) ];

% Now compute the descriptors
[f_so_lr, d_so_lr]		=	vl_dsift( img_gray_lr_flip, 'size', scale_one );
[f_st_lr, d_st_lr]		=	vl_dsift( img_gray_lr_flip, 'size', scale_two );
[f_so_td, d_so_td]		=	vl_dsift( img_gray_td_flip, 'size', scale_one );
[f_st_td, d_st_td]		=	vl_dsift( img_gray_td_flip, 'size', scale_two );

% Need to re-compute the region of interest since images have been flipped.
roi_lr					=	[ size(img_gray,2)-imstruct.roi(1) imstruct.roi(2:3) ];
roi_td					=	[ imstruct.roi(1) size(img_gray,1)-imstruct.roi(2) imstruct.roi(3:4) ];

sift_data_pos_lr		=	sift_compute_pos_samples( fids_lr_flip, f_so_lr, f_st_lr, ...
								d_so_lr, d_st_lr );
sift_data_pos_td		=	sift_compute_pos_samples( fids_td_flip, f_so_td, f_st_td, ...
								d_so_td, d_st_td );

sift_data_neg_lr		=	sift_compute_neg_samples( fids_lr_flip, f_so_lr, f_st_lr, ...
								d_so_lr, d_st_lr, scale_one, roi_lr, sift_params.neg_samples );
sift_data_neg_td		=	sift_compute_neg_samples( fids_td_flip, f_so_td, f_st_td, ...
								d_so_td, d_st_td, scale_one, roi_td, sift_params.neg_samples );

% First concatenate all the current data into a matrix.
sift_data				=	[ sift_data_pos sift_data_pos_lr sift_data_pos_td ...
							  sift_data_neg sift_data_neg_lr sift_data_neg_td ];

% Remember first half are positive samples, next half are negative samples.
example_sign			=	[ ones(1, size(sift_data, 2)/2) -1*ones(1, size(sift_data, 2)/2) ];

fprintf( 'Flipping Done. Now Rotating Images to compute Positive / Negative Samples\n' );
% Rotate the image by a specified amount in clockwise or counter-clockwise direction
% Do this for some number of times and include all positive and negative samples.

for n_rot = 1 : sift_params.num_rotations
	% First generate random rotation value, that is not 0.
	% For now assume all angles are integeres.
	% Positive values represent clockwise rotation, negative represent anti-clockwise rotation.
	rot_val					=	0;
	while ~rot_val
		rot_val				=	randi( [ sift_params.min_rot_angle sift_params.max_rot_angle ], 1, 1 );
	end

	% Now compute the rotated image and fiducials and rois
	[img_gray_rot, ...
	fids_rot, roi_rot]		=	rotate_image_and_fiducials( img_gray, fids, imstruct.roi, rot_val );
	[f_so_rot, d_so_rot]	=	vl_dsift( img_gray_rot, 'size', scale_one );
	[f_st_rot, d_st_rot]	=	vl_dsift( img_gray_rot, 'size', scale_two );
	
	% Now compute the positive and negative samples.
	sift_data_pos_rot		=	sift_compute_pos_samples( fids_rot, f_so_rot, f_st_rot, ...
									d_so_rot, d_st_rot );
	sift_data_neg_rot		=	sift_compute_neg_samples( fids_rot, f_so_rot, f_st_rot, ...
									d_so_rot, d_st_rot, scale_one, roi_rot, sift_params.neg_samples );

	sift_data				=	[ sift_data sift_data_pos_rot sift_data_neg_rot ];
	example_sign			=	[ example_sign ones(1, size(sift_data_pos_rot, 2)) ...
											-1*ones(1, size(sift_data_neg_rot, 2)) ];
end

% Converting sift_data from uint8 to double, for svmtrain.
sift_data = double(sift_double);
