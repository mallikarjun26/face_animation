function [ euclideanDistance ] = findSimilarityScore( image_1, image_2 )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    init;
    
    [DETS_1,PTS_1,DESCS_1]=findFiducialPoints(opts,image_1,true);
    [DETS_2,PTS_2,DESCS_2]=findFiducialPoints(opts,image_2,true);
    
    vectorMatrix = [DESCS_1'; DESCS_2'];
    
    euclideanDistance = pdist(vectorMatrix);
    
end

