function [facenums, tracknums, diffidx] = computeTrackNumbers( facemap, dist_adjacency, pt_indx, frameToTrack, idx, diffval )
% function tracknums = computeTrackNumbers( facemap, dist_adjacency, idx )
% This function takes as argument 'idx' - a set of indices into the variable 'dist_adjacency'
% and finds out the track numbers of the faces corresponding to each element in 'idx'
% facemap  		- Variable that specifies paths to face images. Make sure tha
%					each element of facemap is a string that contains the *complete* path
% 					to the face image.
% dist_adjacency - adjacency matrix of the graph formed by selected faces.
% pt_indx		 - the index of faces chosen to form the graph
% frameToTrack   - Cell data that contains the mapping of frame boundaries to track numbers.
% idx			 - indices into 'dist_adjacency' for which you want to find out these numbers.
%				   size Nx1.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Compute idx as follows
%                   idxtmp = find( dist_adjacency ~= Inf ) ;
%                   [srtval, srtidx] = sort( dist_adjacency( idxtmp ) ;
%                   idxdiff = find( srtval < some_value ) ;
%                   idx = idxtmp( idxdiff ) ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% diffval		 - Optional argument that specifies the minimum number of tracks that faces have to
% 					be apart by
%
%
% Output
% facenums 		 - Nx2 matrix where each row contains the face number in the database corresponding
% 					to index in 'idx'
% tracknums 	 - Nx2 matrix where each row contains the track number in the database corresponding
% 					to index in 'idx'
% diffidx		 - Optional variable that returns indices into tracknums of faces that are greater
%					than 'diffval' apart. If 'diffval' is not specified, this output is set to []

% First compute number of tracks
nTracks = length(frameToTrack{1}) ;
    % and number of indices
nIndices = length(idx) ;

% Now compute the face numbers for each index.
[i, j] = ind2sub( size( dist_adjacency ), idx ) ;
i = pt_indx(i) ;
j = pt_indx(j) ;

% facemap{1} is of the format '/path/to/image/1024_0.jpg'
% where idxbegin finds the location of the last '/' just before 1024_0.jpg
idxbegin = max( find( facemap{1} == '/' ) ) + 1 ;

% Variable that stores the frame numbers for each face set.
facenums = zeros( nIndices, 2 ) ;

for x = 1 : nIndices
	facenums(x, :) = [str2num( facemap{i(x)}(idxbegin:end-6) ) str2num( facemap{j(x)}(idxbegin:end-6) )] ;
end

% Variable that stores the track numbers for each track.
tracknums = zeros( nIndices, 2 ) ;

% Now for each frame number find the corresponding track number
for x = 1 : nIndices
	tracknums(x, :) = [ nTracks-sum( facenums(x, 1) < frameToTrack{2} )+1 ...
						nTracks-sum( facenums(x, 2) < frameToTrack{2} )+1 ] ;
end

if nargin < 6
	diffidx = [] ;
else
	diffidx = find( abs( tracknums(:, 1) - tracknums(:, 2) ) > diffval ) ;
end
