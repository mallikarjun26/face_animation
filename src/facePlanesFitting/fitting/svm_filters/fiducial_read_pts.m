function pts = fiducial_read_pts( fiducial_file_path, fiducial_read_params )
% function pts = fiducial_read_pts( filename )
% Reads fiducial points from a pts file.

file_id		=	fopen( fiducial_file_path );
pts_cell	=	textscan( file_id, '%f %f', 'HeaderLines', 3 );
pts			=	[ pts{1} pts{2} ];
