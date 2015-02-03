function [video_mat] = intensity_normalization(video_obj) 
  
  video_mat  = read(video_obj, [1 Inf]);
  if(size(video_mat, 3) ~= 3)
    error(['Video is not a color video! Please provide a color video']);
  end
  
  frame_size_x    = size(video_mat, 1);
  frame_size_y    = size(video_mat, 2);
  numberOfFrames  = size(video_mat, 4);
  
  rgb_mean = double(zeros(3, 1));
  for i=1:3
    rgb_mean(i, 1) = mean(mean(mean((double(video_mat(:,:,i,:))))));
  end
  
  for i=1:numberOfFrames 
    for j=1:3
      local_mean          = mean(mean((double(video_mat(:,:,j,i)))));
      video_mat(:,:,j,i)  = uint8(video_mat(:,:,j,i) * (rgb_mean(j, 1) / local_mean));
    end
  end
  
end