clear all; clc;

load ~/FaceAnimation/JNData/Faces5000/intermediate_results/bounding_boxes.mat;
load ~/FaceAnimation/JNData/Faces5000/intermediate_results/face_map.mat;
load ~/FaceAnimation/src/feature_representation/featureVector_edgeWeight_extraction/face_p99.mat

idx 			=	randi(4735, 1, 1);
while isempty( bounding_boxes{idx} )
	fprintf( '%d index is empty\n', idx );
	idx 		=	randi(4735, 1, 1);
end

f				=	fopen( '~/FaceAnimation/JNData/Faces5000/ROI/ROI.txt', 'r' );
roi_cell		=	textscan( f, '%s %u %u %u %u' );
im 				= 	imread( sprintf( '~/FaceAnimation/JNData/Faces5000/Frames/%s.jpg', mapping{idx}(26:end-6)) );
im_face			=	imread( sprintf( '~/FaceAnimation/JNData/%s', mapping{idx} ) );

idx_roi			=	find( arrayfun( @(x) ( isequal( x{1}, mapping{idx}(26:end-4) ) ), roi_cell{1} ) );
roi				=	[ roi_cell{2}(idx_roi) roi_cell{3}(idx_roi) roi_cell{4}(idx_roi) roi_cell{5}(idx_roi) ];
roi				=	double( roi );

bxs				=	bounding_boxes{idx}.xy ;
fids_noscale	=	[ bxs(:,1)+bxs(:,3) bxs(:,2)+bxs(:,4) ]/2;

fids			=	fids_noscale;
width_extra		=	min(0, roi(1) - 0.2*roi(3)) + min(0, size(im, 2) - roi(1) - 1.2*roi(3));
height_extra	=	min(0, roi(2) - 0.2*roi(4)) + min(0, size(im, 1) - roi(2) - 1.2*roi(4));
fids(:,1)		=	fids(:,1) / 200 * (1.4 * roi(3) + width_extra);
fids(:,2)		=	fids(:,2) / 200 * (1.4 * roi(4) + height_extra);
fids(:,1)		=	fids(:,1) + max(0, roi(1) - 0.2 * roi(3));
fids(:,2)		=	fids(:,2) + max(0, roi(2) - 0.2 * roi(4));
fids 	 		=	round(fids);

rotate_val		=	randi([-15 15], 1, 1);
while ~rotate_val
	rotate_val	=	randi([-15 15], 1, 1);
end

[im_rot, fids_rot, roi_rot] = rotate_image_and_fiducials( im, fids, roi, rotate_val ) ;

subplot(2,2,1); imagesc( im_face ); hold on; plot( fids_noscale(:, 1), fids_noscale(:, 2), 'r.' );
subplot(2,2,2); imagesc( im ); hold on; plot( fids(:, 1), fids(:, 2), 'b.' );
subplot(2,2,3); imagesc( im_rot ); hold on; plot( fids_rot(:, 1), fids_rot(:, 2), 'g.' );

det				=	detect(im_face, model, -1);
det				=	clipboxes(im_face, det);
det				=	nms_face(det, 0.3);
fx				=	det.xy(:,1)+det.xy(:,3);
fy				=	det.xy(:,2)+det.xy(:,4);

subplot(2,2,4); imagesc( im_face ); hold on; plot( fx/2, fy/2, 'c.' );

rotate_dir		=	'clockwise';
if rotate_val < 0
	rotate_dir	=	'counter-clockwise';
end

fprintf( 'Face of %d sample is being rotated here by %d degrees %s\n', idx, rotate_val, rotate_dir );
