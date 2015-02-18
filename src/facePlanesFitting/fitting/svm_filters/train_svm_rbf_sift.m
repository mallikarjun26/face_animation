function SVMStruct = train_svm_rbf_sift( data_extract_function, feature_compute_function, extract_params, feature_params, train_params )
% function SVMStruct = train_svm_rbf_sift( data_extract_function, % sift_compute_function, extract_params, sift_params, kernel )
% Input
% data_extract_function 	-	Handler to function that extracts data from directories to form
% 									training samples
% feature_compute_function	- 	Function that computes features on the data extracted by the
%									data_extract_function function.
% extract_params			-	struct of parameters passed to data_extract_function
%								*	fiducial_path 	- Path to location where fiducial points files 
%										are stored.
%								*	fiducial_fmt	- Format of each fiducial point file.
%								*	roi_path		- Path to location where bounding box points
%										file is stored.
%								*	roi_fmt			- Format of bounding box file.
%								*	image_path 		- Path to location where image files are stored.
%								*	image_fmt		- Format of each image.
%								*	fiducial_read	- Handle to function that reads fiducial points.
%								*	roi_read		- Handle to function that reads bounding box points.
% feature_params			-	struct of parameters passed to feature_compute_function
% train_params				-	struct of parameters passed to this function.
%								*	kernel			- Choice of training kernel, 'rbf',
%										'polynomial', etc..
%								*	kernel_params	- Names of parameters passed to each kernel
%										Can be a cell of names, or a scalar.
%								*	kernel_values	- Values that these kernel parameters should
%										take. Can be a cell of values, or a scalar.

if nargin < 6
	% Set the default parameters for the training here.
	train_params.kernel 		= 	'rbf';
	train_params.kernel_params	=	'RBF_Sigma';
	train_params.kernel_values	= 	0.2;
end

% Call the data_extract_function to extract all the data.
% This function extracts patches from images passed to it, from the fiducial points
% whose path is located in extract_params structure.
% This function calls the sift_compute_function to extract all the sift features.
fprintf( 'Collecting training data...\n' ) ;
[train_data, train_groups] = data_extract_function( extract_params, sift_compute_function, sift_params );

% Finally call the svmtrain function with the RBF kernel.
% Currently this code only works for scalar kernel_params and kernel_values
% Needs to be extended for cell arguments by passing it to the function
% as variable arguments.
fprintf( 'Calling SVM routines for training...\n' );
SVMStruct = svmtrain( train_data, train_groups, 'Kernel_Function', train_params.kernel, ...
								train_params.kernel_params, train_params.kernel_values );
