function [train_data, train_groups] = extract_image_patches( extract_params, feature_compute_function, feature_params )
% function [train_data, train_groups] = extract_image_patches( extract_params, feature_compute_function, feature_params )


% This function takes all the images one-by-one, and for each one computes the sift vector around
% each fiducial patch. Finally it stacks all these examples as either 'positive' examples or 
% 'negative' ones, and just keeps the sift vectos and discards the rest.
fiducial_names 	= 	dir( sprintf( '%s/*.%s', extract_params.fiducial_path, ...
											 extract_params.fiducial_fmt ) );
roi_names		=	dir( sprintf( '%s/*.%s', extract_params.roi_path, ...
											 extract_params.roi_fmt ) );
images_names 	=	dir( sprintf( '%s/*.%s', extract_params.image_path, ...
											 extract_params.image_fmt ) );

train_data		= 	[];
train_groups	=	[];

flen			=	length( extract_params.fiducial_fmt );
ilen			=	length( extract_params.image_fmt );
roi				=	extract_params.roi_read( sprintf( '%s/%s', extract_params.roi_path, ...
						roi_names(i).name ), extract_params.roi_read_params );

% For each image
for i = 1 : length(images_names)

	% First assert the fact that you are reading the same image and pts file.
	assert( images_names(i).name( 1:end-ilen-1 ) == fiducial_names(i).name( 1:end-flen-1 ) ) ;

	% Then read the image and the fiducial.
	imstruct.img		=	imread( sprintf( '%s/%s', extract_params.image_path, images_names(i).name ) );
	imstruct.roi		=	roi(i, :);
	fids				=	extract_params.fiducial_read( sprintf( '%s/%s', extract_params.fiduclai_path, ...
								fiducial_names(i).name ), extract_params.fiducial_read_params );

	% For all fiducial markers.
	[td, tg] 		=	feature_compute_function( imstruct, fids, feature_params );
	train_data		=	[train_data td];
	train_groups	=	[train_groups tg];
end
