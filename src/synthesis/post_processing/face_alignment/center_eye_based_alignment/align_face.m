function output = align_face(frame, left_eye, right_eye)

  output = [];
  imshow(frame);
  size_x = size(frame, 1);
  size_y = size(frame, 2);

  %if((right_eye(1,1) - left_eye(1,1)) < (size_x/3))
   % disp('waste only');
    %return;
  %end
  
  center_eye = uint32((left_eye + right_eye)/2);
  half_interocular_distance = uint32(center_eye - left_eye);
  
  left_top = uint8(zeros(1,2));
  left_top(1,1) = uint8((center_eye(1,1)) - (1.5*half_interocular_distance(1,1)));
  left_top(1,2) = uint8((center_eye(1,2)) - (1.5*half_interocular_distance(1,1)));
  
  right_bottom = uint8(zeros(1,2));
  right_bottom(1,1) = uint8((center_eye(1,1)) + (1.5*half_interocular_distance(1,1)));
  right_bottom(1,2) = uint8((center_eye(1,2)) + (3*half_interocular_distance(1,1)));
  
  temp_rect = [left_top (right_bottom - left_top)];
  
  if( left_top(1,1)>0 && left_top(1,2)>0 && right_bottom(1,1)<size_x && right_bottom(1,2)<size_y )
    output = imcrop(frame, temp_rect);
    output = imresize(output, [150 150]);
  end
  
end