% Builds feature vector for each of the faces. Finds fiducial points and provides LBP feature vectors for each of the fiducial parts in featureVectors.txt

function main(inputPath, outputPath)

  current_folder = cd;
  ramanan_folder = [current_folder '/../../../feature_representation/featureVector_edgeWeight_extraction'];
  addpath(ramanan_folder);
  
  compile;
  load face_p99.mat
  % 5 levels for each octave
  model.interval = 5;
  % set up the threshold
  model.thresh = min(-0.65, model.thresh);

  video_ptr = VideoReader(inputPath);
  video = read(video_ptr);
  output_video_ptr = VideoWriter(outputPath);
  output_video_ptr.FrameRate = 24;
  open(output_video_ptr);
  number_of_frames = size(video, 4);
  
  for i=1:number_of_frames
    disp(['Processing ' num2str(i) ' frame']);
    frame = video(:,:,:,i);
    bs = detect(frame, model, model.thresh);
    bs = clipboxes(frame, bs);
    bs = nms_face(bs,0.3);
    if(size(bs, 2) ==0)
      continue;
    end
    [left_eye, right_eye] = get_eye_loc(bs);
    output_frame = align_face(frame, left_eye, right_eye);
    if(size(output_frame, 1) == 0)
      continue;
    end
    writeVideo(output_video_ptr, output_frame);
  end
  
  close(output_video_ptr);
  
end

function [left_eye, right_eye] = get_eye_loc(bs)

  index = 11;
  x = uint8(bs.xy(index,1) + (bs.xy(index,3)/2));
  y = uint8(bs.xy(index,2) + (bs.xy(index,4)/2));
  left_eye = [x y];

  index = 20;
  x = uint8(bs.xy(index,1) + (bs.xy(index,3)/2));
  y = uint8(bs.xy(index,2) + (bs.xy(index,4)/2));
  right_eye = [x y];

end




















