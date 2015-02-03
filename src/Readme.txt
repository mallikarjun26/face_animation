Work has been pipelined in three folders. This file gives the overview of the entire pipeline. Use cases are written in each of the folder's readme.

----------------------------------------------------------------------------------------------------
build_dataset: 
----------------------------------------------------------------------------------------------------
    1. Extract faces from a video.
    2. Manually filter wanted faces.
    3. Create a list of selected faces and create a map for file name to a number and store it in ListOfFaces.txt
    4. Extract frames of those selected faces from the video for further use and store it in Frames folder.
    5. HeshanShotDet: This part does the track(shots) segmentation in the video and stores the frame number range and corresponding track number in the file frameShotMap.txt

----------------------------------------------------------------------------------------------------
feature_representation:
----------------------------------------------------------------------------------------------------
    1. Feature extraction for each face based on fiducial points, pose using Local Binary Pattern and Deva Ramanan et al's fiducial point detector.
    2. Edge weight calculation based on top scoring 15 common fiducial points between two faces.
    3. Non-linear edge weight scaling based on average minimum between track edge weights.
    4. Histogram of edge weights done for analysis.

    face_release1.0_basic
        1. ESmain.m Create featureVector.
        2. findCommonParts.m Create edgeWeights.

    EdgeWeightTransform
        1. Does statistics and finds the transformed edge weights.

----------------------------------------------------------------------------------------------------
sysnthesis:
----------------------------------------------------------------------------------------------------
    1. Graph construction and traversals based on 'Greedy Next hop' and 'Dijkstra shortest path'. Video synthesis of traversals.
    2. Post processing of the synthesized video. Intensity normalization and interpolation.
       
----------------------------------------------------------------------------------------------------
tensor_analysis
----------------------------------------------------------------------------------------------------
    1. Video as a 3D tensor's analysis with rank and factorization methods.


----------------------------------------------------------------------------------------------------
util: Mostly unused code
----------------------------------------------------------------------------------------------------
    1. 
