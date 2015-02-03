function image = crop_face(image, eye_left, eye_right, offset_pct, dest_sz)

  %image = imread(image_path);

  % calculate offsets in original image
  offset_h = offset_pct(1,1)*dest_sz(1,1);
  offset_v = offset_pct(1,2)*dest_sz(1,2);
  
  % get the direction
  eye_direction = [(eye_right(1,1) - eye_left(1,1)) (eye_right(1,2) - eye_left(1,2))];
  
  % calc rotation angle in radians
  rotation = atan2(eye_direction(1,2), eye_direction(1,1));
  
  % distance between them
  dist = Distance(eye_left, eye_right);
  
  % calculate the reference eye-width
  reference = dest_sz(1,1) - 2*offset_h;
  
  % scale factor
  scale = dist/reference;
  
  % rotate original around the left eye
  image = ScaleRotateTranslate(image, eye_left, rotation);
  
  % crop the rotated image
  crop_xy = [(eye_left(1,1) - scale*offset_h) (eye_left(1,2) - scale*offset_v)];
  crop_size = [(dest_sz(1,1)*scale) (dest_sz(1,2)*scale)];
  rect         = zeros(1, 4);
  rect(1,1)    = crop_xy(1,1);
  rect(1,2)    = crop_xy(1,2);
  rect(1,3)    = crop_xy(1,1)+crop_size(1,1);
  rect(1,4)    = crop_xy(1,2)+crop_size(1,2);

  image = imcrop(image, rect);
  image = imresize(image, [200 200]);

end

function [image] = ScaleRotateTranslate(image, center, angle)

  nx = center(1,1);
  x = nx;
  ny = center(1,2);
  y = ny;
  sx = 1;
  sy = 1;
  
  cosine = cos(angle);
  sine = sin(angle);
  a = cosine/sx;
  b = sine/sx;
  c = x-nx*a-ny*b;
  d = -sine/sy;
  e = cosine/sy;
  f = y-nx*d-ny*e;
  
  tform = maketform('affine',[a b 0; d e 0; 0 0 1]);
  image = imtransform(image, tform);

end

function distance = Distance(p1,p2)
  dx = p2(1,1) - p1(1,1);
  dy = p2(1,2) - p1(1,2);
  distance = sqrt((dx*dx) + (dy*dy));
end
