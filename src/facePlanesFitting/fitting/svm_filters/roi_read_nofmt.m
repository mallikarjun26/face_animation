function roi = roi_read_nofmt( roi_file_path, roi_read_params )
% function roi = roi_read_nofmt( roi_file_path, roi_read_params )
% Very simple function to read roi's from a file. roi_read_params is currently
% not used as a result.

file_id		=	fopen( roi_file_path, 'r' ) ;
roi_cell	=	textscan( file_id, '%u_%u %u %u %u %u' );
roi			=	[ roi_cell{3} roi_cell{4} roi_cell{5} roi_cell{6} ];
