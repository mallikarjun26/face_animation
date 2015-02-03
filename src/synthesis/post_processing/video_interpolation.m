function [output_video_mat] = video_interpolation(video_mat, video_path) 

    temp_string_array = strsplit(video_path, '.');
    distance_text_path = [temp_string_array{1,1} '_hop_distances.txt'];
    distance_text_ptr = fopen(distance_text_path);
    frame_size_x    = size(video_mat, 1);
    frame_size_y    = size(video_mat, 2);
    numberOfFrames  = size(video_mat, 4);
  
    
    %% process text file
    tLine = fgets(distance_text_ptr);
    tStrSplit = strsplit(tLine, ' ');
    number_of_hops  = size(tStrSplit, 2)-1;
    distance_matrix = zeros(1, number_of_hops);
    for i=1:number_of_hops
       distance_matrix(1,i) = str2num(tStrSplit{1,i}); 
    end
    
    min_distance = min(distance_matrix);
    modified_distance_matrix = [];
    for i=1:number_of_hops-1
        if(distance_matrix(1,i) < (2 * min_distance))
            modified_distance_matrix = [modified_distance_matrix 0 distance_matrix(1,i)];
        else
            modified_distance_matrix = [modified_distance_matrix 0 0 0 0 distance_matrix(1,i)];
        end
    end
    
    %% process video mat for interpolation
    modified_number_of_frames   = size(modified_distance_matrix, 2)+1;
    output_video_mat            = zeros(frame_size_x, frame_size_y, 3, modified_number_of_frames);
    interpolated_locations      = 1:modified_number_of_frames;
    
    for i=1:frame_size_x
        for j=1:frame_size_y
            for k=1:3
                before_interpolation        = double(video_mat(i,j,k,:));
                before_interpolation        = reshape(before_interpolation, [1,size(before_interpolation,4)]);
                frame_locations             = find(modified_distance_matrix);
                interpolated_values         = interp1(frame_locations, before_interpolation, interpolated_locations, 'spline');
                output_video_mat(i,j,k,:)   = interpolated_values;
            end
        end
    end
    

end