% Does intensity normalization and interpolation based on cublic spline on the videos synthesized.

function post_processing(output_path)

  disp('---------------- POST PROCESSING --------------------');

  % Initialization
  videos_path = [output_path '/videos'];
  output_videos_path = [output_path '/interpolated_videos'];
  avi_videos_path = fullfile([output_path '/videos/*.avi']);

  videos_name = dir(avi_videos_path);
  numberOfVideos = size(videos_name,1);
  
  for i=1:numberOfVideos
    
    disp(['Processing ' int2str(i)  ' video']);
    
    video_path = [videos_path '/' videos_name(i).name];
    
    try
        video_obj  = VideoReader(video_path);
    catch
        disp('An error occurred while retrieving information from the internet.');
        disp('Execution will continue.');
        continue;
    end
        
    %% Intensity normalization
    video_mat = intensity_normalization(video_obj);
    %dump_video(video_mat, '~/Downloads/intensity_normalized.avi');
    
    %% Interpolation
    interpolated_video_mat = video_interpolation(video_mat, video_path);
    output_video_path = [output_videos_path '/' videos_name(i).name];
    dump_video(interpolated_video_mat, output_video_path);
    
    %% Face cropping
    
  end
  

end
