function post_processing(output_path)

  disp('---------------- POST PROCESSING --------------------');

  % Initialization
  videos_path = [output_path '/videos'];
  avi_videos_path = fullfile([output_path '/videos/*.avi']);

  videos_name = dir(avi_videos_path);
  numberOfVideos = size(videos_name,1);
  
  for i=1:numberOfVideos
    
    disp(['Processing ' int2str(i)  ' video']);
    
    video_path = [videos_path '/' videos_name(i).name]
    
    %% Intensity normalization
    video_mat = intensity_normalization(video_path);
    %dump_video(video_mat, '~/Downloads/intensity_normalized.avi');
    
    %% Interpolation
    interpolated_video_mat = video_interpolation(video_mat, video_path);
    dump_video(interpolated_video_mat, '~/Downloads/interpolated_normalized.avi');
    
    %% Face cropping
    
  end
  

end
