function showShapes( facemap, facebbox, dist_adjacency, pt_indx, idx, nFaces )
% function showShapes( dist_adjacency, pt_indx, idx )
% This function shows the two images with shapes plotted
% for the index 'idx' into the variable 'dist_adjacency' where
% the elements of 'dist_adjacency' themselves index into the 
% Face Database through the variable 'pt_indx'
% facemap  		- Variable that specifies paths to face images. Make sure tha
%					each element of facemap is a string that contains the *complete* path
% 					to the face image.
% facebbox  	- Variable that stores the fitted face model to each face in the
%					database
% dist_adjacency - adjacency matrix of the graph formed by selected faces.
% pt_indx		 - the index of faces chosen to form the graph
% idx			 - vector containing all the indices into 'dist_adjacency'
%					for which you want to plot and see faces.
% nFaces		 - number of faces to show per row. Ideally should take a value
%					between 3 & 10. Optional argument
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Important: add the path to the set of face codes. This is usually easily done by using genpath
% addpath( genpath( 'Path/to/faces/src/' ) ) ;
% This is essential to run this code.

if nargin < 6
	nFaces = 10 ;
end

% First compute row and column indices from single dimension
% indices
[i, j] = ind2sub( size(dist_adjacency), idx ) ;

% Then use them to index into files in the database
i = pt_indx(i) ;
j = pt_indx(j) ;

% Now read all the images and plot them along with
% their shapes.
for x = 0 : round(length(idx)/nFaces) ;
	for y = 1 : min(nFaces-1, length(idx)-x*nFaces)
		imi = imread( facemap{i( x*nFaces+y )} ) ;
		imj = imread( facemap{j( x*nFaces+y )} ) ;
		subplot(2, nFaces, y) ; showboxes(imi, facebbox{i(x*nFaces+y)}, 1:13) ;
		subplot(2, nFaces, nFaces+y) ; showboxes(imj, facebbox{j(x*nFaces+y)}, 1:13) ;
	end
    if y == (nFaces-1)
		fprintf( 'Displaying %d images, press any key to display the next %d \n', nFaces, nFaces ) ;
		pause ;
		clf ;
	end
end
