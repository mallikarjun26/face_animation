function post_processing(output_path)

  disp('---------------- POST PROCESSING --------------------');

  % Initialization
  videos_path = [output_path '/videos'];

  videos_name = dir(videos_path);
  videos_name = videos_name(3:size(videos_name,1),:);
  numberOfVideos = size(videos_name,1);
  
  for i=1:numberOfVideos
    
    disp(['Processing ' int2str(i)  ' video']);
    
    video_path = [videos_path '/' videos_name(i).name];
    
    %% Intensity normalization
    video_mat = intensity_normalization(video_path);
    %dump_video(video_mat, '~/Downloads/intensity_normalized.avi');
    
    %% Interpolation
    video_mat = video_interpolation(video_mat);

    %% Face cropping
    
  end
  

end