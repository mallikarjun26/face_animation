function dump_video(video_mat, path)

  number_of_frames = size(video_mat, 4);

  video_obj = VideoWriter(path);
  open(video_obj);
  
  for i=1:number_of_frames
    temp_frame = video_mat(:,:,:,i);
    writeVideo(video_obj, temp_frame);
  end
  close(video_obj);

end