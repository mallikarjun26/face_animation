% creates face aligned video

% reads the node list of traversal. align the face from the node and make video.

function main(output_folder)

  current_folder = cd;
  ramanan_folder = [current_folder '/../../../../feature_representation/featureVector_edgeWeight_extraction'];
  addpath(ramanan_folder);
  
  videos_folder = [output_folder '/videos'];
  node_list_files = dir(fullfile([videos_folder '/*node_list.txt']));
  list_of_faces_path = [output_folder '/ListOfFaces.txt'];
  node_to_file_map = get_list_of_faces(list_of_faces_path);
  roi_path = [output_folder '/ROI/ROI.txt'];
  roi = get_roi(roi_path);

  compile;
  load face_p99.mat
  % 5 levels for each octave
  model.interval = 5;
  % set up the threshold
  model.thresh = min(-0.65, model.thresh);

  number_of_videos = size(node_list_files, 1);
  for i=1:number_of_videos
    temp_node_list_file = [videos_folder '/' node_list_files(i,1).name];
    temp_node_list_ptr = fopen(temp_node_list_file);
    output_video_path = get_output_video_name(node_list_files(i,1).name, videos_folder);
    output_video_ptr = VideoWriter(output_video_path);
    output_video_ptr.FrameRate = 24;
    open(output_video_ptr);
    nodes = textscan(temp_node_list_ptr, '%d');
    number_of_nodes = size(nodes{1,1}, 1);
    
    for j=1:number_of_nodes
      node = nodes{1,1}(j,1);
      face_frame = get_frame(node, node_to_file_map, roi, output_folder);
      output_frame = get_aligned_face(face_frame, model);
      if(size(output_frame, 1) == 0)
        continue;
      end
      writeVideo(output_video_ptr, output_frame);
    end
    close(output_video_ptr); 
  end
end

function face_frame = get_frame(node, node_to_file_map, roi, output_folder)

  frame_number_with_locId = node_to_file_map{node+1,1};
  t_split = strsplit(frame_number_with_locId, '_');
  frame_path = [output_folder '/Frames/' t_split{1,1} '.jpg'];
  full_frame = imread(frame_path);

  t_split = strsplit(frame_number_with_locId, '.');
  single_roi = roi(t_split{1,1});

  x1_o    = single_roi(1,1); 
  y1_o    = single_roi(1,2);
  width   = single_roi(1,3);
  height  = single_roi(1,4);

  x1 =  round(   x1_o  - (width * 0.2)  );
  x2 =  round(   (x1_o+ width) + (width * 0.2)  );
  y1 =  round(     y1_o  -   (height*0.2) )  ;
  y2 =  round(    (y1_o + height)   + (height*0.2)   );
  
  x1 = max(x1, 1);
  x2 = min(x2, size(full_frame,2));
  y1 = max(y1, 1);
  y2 = min(y2, size(full_frame,1));
  
  face_frame = full_frame(y1:y2, x1:x2, :);
  face_frame = imresize(face_frame, [200 200]);

end

function roi = get_roi(roi_path)

  disp('Entered get_roi');
  roi_ptr = fopen(roi_path);
  roi_content = textscan(roi_ptr, '%s %u %u %u %u');
  roi_content_c1 = roi_content{1,1};
  roi_content_c2 = roi_content{1,2};
  roi_content_c3 = roi_content{1,3};
  roi_content_c4 = roi_content{1,4};
  roi_content_c5 = roi_content{1,5};
  number_of_rois = size(roi_content_c1,1);

  roi = containers.Map;

  for i=1:number_of_rois
    roi(roi_content_c1{i,1}) = [roi_content_c2(i,1)  roi_content_c3(i,1) roi_content_c4(i,1) roi_content_c5(i,1)];     
  end

  disp('Leaving get_roi');
end

function node_to_file_map = get_list_of_faces(list_of_faces_path)
  disp('Entered get_list_of_faces');
  list_of_faces_ptr = fopen(list_of_faces_path);
  file_content = textscan(list_of_faces_ptr, '%s %u');
  node_to_file_map = file_content{1};
  number_of_nodes = size(node_to_file_map);
end

function output_video_path =get_output_video_name(node_file, videos_folder)
  t_split = strsplit(node_file, '_node'); 
  output_video_path = [videos_folder '/' t_split{1,1} '_aligned.avi'];
end

function [output_frame] = get_aligned_face(frame, model)
  output_frame = [];
  bs = detect(frame, model, model.thresh);
  bs = clipboxes(frame, bs);
  bs = nms_face(bs,0.3);
  if(size(bs, 2) ==0)
    return;
  end
  [left_eye, right_eye, chin] = get_fid_loc(bs);
  output_frame = align_face(frame, left_eye, right_eye, chin);
  disp('yes');
end

function [left_eye, right_eye, chin] = get_fid_loc(bs)

  index = 15;
  x = uint32((bs.xy(index,1) + bs.xy(index,3))/2);
  y = uint32((bs.xy(index,2) + bs.xy(index,4))/2);
  left_eye = [x y];

  index = 26;
  x = uint32((bs.xy(index,1) + bs.xy(index,3))/2);
  y = uint32((bs.xy(index,2) + bs.xy(index,4))/2);
  right_eye = [x y];
  
  index = 52;
  x = uint32((bs.xy(index,1) + bs.xy(index,3))/2);
  y = uint32((bs.xy(index,2) + bs.xy(index,4))/2);
  right_chin = [x y];
  
  index = 61;
  x = uint32((bs.xy(index,1) + bs.xy(index,3))/2);
  y = uint32((bs.xy(index,2) + bs.xy(index,4))/2);
  left_chin = [x y];
  
  chin = uint32((right_chin + left_chin)/2);
  
end




















