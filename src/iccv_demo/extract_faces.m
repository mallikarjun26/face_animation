function extract_faces(video_path, path)

    %
    clc; close all;
    video_handle = VideoReader(video_path); 
    
    %
    video_tensor = read(video_handle);
    number_of_frames = get(video_handle, 'NumberOfFrames');

    %
    facemap = cell(1, number_of_frames);
    face_roi = cell(1, number_of_frames);
    
    figure;
    FDetect = vision.CascadeObjectDetector;
    for i=1:number_of_frames
        temp_frame = video_tensor(:,:,:,i);
        imshow(temp_frame); hold on
        
        %Returns Bounding Box values based on number of objects
        BB = step(FDetect, temp_frame);
       
        for j = 1:size(BB,1)
           rectangle('Position',BB(j,:),'LineWidth',5,'LineStyle','-','EdgeColor','r');
           
           if(~is_john_oliver(BB(j,:), temp_frame));
               continue;
           end
           
           roi = BB(j,:);
        end
        
        [im, roi] = get_resized_im(temp_frame, roi);
        facemap{i} = [path '/iccv_demo/images/' num2str(i) '.jpg'];
        face_roi{i} = roi;
        imwrite(im, facemap{i});
        
        title('Face Detection');
        hold off;       
    end

end

function [im, roi] = get_resized_im(temp_frame , roi)

    roi(1) = roi(1) - (0.15 * roi(3));
    roi(2) = roi(2) - (0.15 * roi(4));
    roi(3) = 0.3 * roi(3);
    roi(4) = 0.3 * roi(4);

    x1 = roi(1,1); y1 = roi(1,2); 
    x2 = x1 + roi(1,3); y2 = y1 + roi(1,4);
    
    im = temp_frame(y1:y2, x1:x2, :);
    im = imresize(im, [300 300]);
end


function john = is_john_oliver(BB, temp_frame)

    [frame_x, frame_y, ~] = size(temp_frame);

    x = BB(1,1) + (BB(1,3)/2);
    y = BB(1,2) + (BB(1,4)/2);
    
    if( ( x > 0.3*(frame_x) ) && ( y < 0.7*(frame_y) ) )
        john = 1;
    else
        john = 0;
    end
    
end
  
