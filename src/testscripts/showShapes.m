function showShapes( facemap, facebbox, dist_adjacency, pt_indx, idx )
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

% First compute row and column indices from single dimension
% indices
[i, j] = ind2sub( size(dist_adjacency), idx ) ;

% Then use them to index into files in the database
i = pt_indx(i) ;
j = pt_indx(j) ;

% Now read all the images and plot them along with
% their shapes.
for x = 0 : round(length(idx)/10) ;
	for y = 1 : min(9, length(idx)-x*10)
		imi = imread( facemap{i( x*10+y )} ) ;
		imj = imread( facemap{j( x*10+y )} ) ;
		subplot(2, 10, y) ; showboxes(imi, facebbox{i(x*10+y)}, 1:13) ;
		subplot(2, 10, 10+y) ; showboxes(imj, facebbox{j(x*10+y)}, 1:13) ;
	end
    if y == 9
		disp('Displaying ten images, press any key to display the next 10') ;
		pause ;
		clf ;
	end
end
