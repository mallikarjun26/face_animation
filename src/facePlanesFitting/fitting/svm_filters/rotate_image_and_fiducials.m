function [img_rot, fids_rot, roi_rot] = rotate_image_and_fiducials( img, fids, roi, rot_val )
% function [img_rot, fids_rot, roi_rot] = rotate_image_and_fiducials( img, fids, roi, rot_val )
% This function simply rotates an image and its corresponding fiducials and roi
% (face region of interest within the image, the bounding box detected by a face detector)
% using the value given in rot_val.
% If rot_val > 0, rotation is clockwise, else it is counter-clockwise.
% Input
% img		-	
% fids		-	
% roi		-	
% rot_val	-	Angle in degrees.
% Algorithm
% - Take a meshgrid of the size of the image.
% - Rotate it by the inverse of the rotation that needs to be applied to the original image.
% - Given the new coordinates, interpolate and pick the colors from the original image at
%		the new coordinates. This is the rotate image.
% - Find the closest points to the fiducial points. These are the new fiducial points.
% - Find the closest points to the roi. The minimum bounding box containing these points
%		is the new roi.

if size(fids, 2) > 2
	fids = fids';
end

[sy, sx, sz]			=	size( img ) ;
num_fids				=	size( fids, 1 );
fids_rot				=	zeros( num_fids, 2 );

% First center fiducials for ease of performing rotation computations.
fids(:, 1)				=	round( fids(:, 1) - sx/2 );
fids(:, 2)				=	round( fids(:, 2) - sy/2 );

% Compute inverse of the desired rotation matrix.
rot_matrix				=	[  cos(rot_val/180*pi)	 sin(rot_val/180*pi); ...
							  -sin(rot_val/180*pi)	 cos(rot_val/180*pi) ];

% Convert roi from [x, y, width, height] format to [xmin ymin xmax ymax] format
roi						=	[roi(1), roi(1), roi(1)+roi(3), roi(1)+roi(3); ...
							 roi(2), roi(2)+roi(4), roi(2), roi(2)+roi(4)];

% Compute the coordinate meshgrid.
[x_coords, y_coords] 	=	meshgrid( 1:sx, 1:sy );
x_coords				=	x_coords - sx/2;					% Centering coordinate system.
y_coords				=	y_coords - sy/2;					% Centering coordinate system.

% Now rotate these coordinates to get the rotated values.
rotated_coords			=	rot_matrix * [ x_coords(:)'; y_coords(:)' ];

% Now interpolate image to get the rotate image.
if sz == 1
	% Gray scale image.
	img_rot				=	zeros( [sy, sx] );
	% Interpolate with bilinear interpolation
	% TODO make interpolation a variable that can be set.
	img_rot(:)			=	interp2( x_coords, y_coords, double(img), ...
								rotated_coords(1, :)', rotated_coords(2, :)', 'linear' );
else
	img_r				=	squeeze( img(:, :, 1) );
	img_g				=	squeeze( img(:, :, 2) );
	img_b				=	squeeze( img(:, :, 3) );
	img_rot_r			=	zeros( [sy, sx] );
	img_rot_g			=	zeros( [sy, sx] );
	img_rot_b			=	zeros( [sy, sx] );
	img_rot_r(:)		=	interp2( x_coords, y_coords, double(img_r), ...
								rotated_coords(1, :)', rotated_coords(2, :)', 'linear' );
	img_rot_g(:)		=	interp2( x_coords, y_coords, double(img_g), ...
								rotated_coords(1, :)', rotated_coords(2, :)', 'linear' );
	img_rot_b(:)		=	interp2( x_coords, y_coords, double(img_b), ...
								rotated_coords(1, :)', rotated_coords(2, :)', 'linear' );
	img_rot				=	cat( 3, img_rot_r, img_rot_g, img_rot_b );
end
img_rot					=	uint8( img_rot );

% Now find out the closest points to each fiducial.
% 'round' does not work here.
[~, fids_rot_idx]		=	ismember( fids, ceil( rotated_coords' ), 'rows' );
[~, fids_rot_idx2]		=	ismember( fids, floor( rotated_coords' ), 'rows' );
idx_zero				=	find( fids_rot_idx == 0 );
fids_rot_idx(idx_zero)	=	fids_rot_idx2(idx_zero);

% If all fiducials are not found, then image has not been adequately padded, because
% rotation of face puts it outside the range of the image space.
assert( isempty(find( fids_rot_idx == 0 )) );

% Compute rotated fiducials.
[fids_rot(:, 2), ...
	fids_rot(:, 1)]		=	ind2sub( [sy, sx], fids_rot_idx );

% Comupte rotated region of interest.
roi_rot_tmp				=	rot_matrix' * roi;
roi_rot					=	[min(roi_rot_tmp(1, :)), min(roi_rot_tmp(2, :)), ...
								max(roi_rot_tmp(1, :)), max(roi_rot_tmp(2, :))];
roi_rot					=	[roi_rot(1), roi_rot(2), roi_rot(3)-roi_rot(1), roi_rot(4)-roi_rot(2)];
