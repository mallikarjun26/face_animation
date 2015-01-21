function [video_quality_1, video_quality_2] = main(inputPath_1, inputPath_2, mode)

    %% Optimization possibilities
     % 1. Initialize the 3D tensor and fill.

    tensor_1 = getTensorFromVideo(inputPath_1);
    tensor_2 = getTensorFromVideo(inputPath_2);
      
    %% Size matching
    [tensor_1, tensor_2] = matchTensorSize(tensor_1, tensor_2);
    
    %% Video analysis
    if(mode == 1)
        video_quality_1 = tensor_3D_analysis(tensor_1);
        video_quality_2 = tensor_3D_analysis(tensor_2);
    end
    
    %% Video merger
    if(mode == 2)
        [o_tensor_1, o_tensor_2] = tensor_merger(tensor_1, tensor_2);
        % Save tensors as video
        saveTensorAsVideo(o_tensor_1, 'output1.avi');
        saveTensorAsVideo(o_tensor_2, 'output2.avi');
    end
end

function [o_tensor] = getTensorFromVideo(inputPath)

    % Frame size
    frameSize = [100 100];

    vidObj = VideoReader(inputPath);

    t_tensor = read(vidObj);
    t_tensor_size = size(t_tensor);
    numberOfFrames = get(vidObj, 'NumberOfFrames');
    o_tensor = zeros(frameSize(1,1), frameSize(1,2), t_tensor_size(1,4));
    
    for i=1:numberOfFrames
          tempFrame      =    rgb2gray(t_tensor(:,:,:,i));
          o_tensor(:,:,i)   =    imresize(tempFrame, frameSize);
    end
    
end

function [o_tensor_1, o_tensor_2] = matchTensorSize(tensor_1, tensor_2)

    size_1 = size(tensor_1);
    size_2 = size(tensor_2);
    
    if(size_1 == size_2)
        o_tensor_1 = tensor_1;
        o_tensor_2 = tensor_2;
        return;
    end
    
    if(size_1(1,3) > size_2(1,3))
        tempSize = size_2(1,3);
        o_tensor_1 = tensor_1(:,:,1:tempSize);
        o_tensor_2 = tensor_2;
    else
        tempSize = size_1(1,3);
        o_tensor_2 = tensor_2(:,:,1:tempSize);
        o_tensor_1 = tensor_1;
    end

end

function saveTensorAsVideo(tensor, path)

    writerObj = VideoWriter(path)
    writerObj.FrameRate = 10;
    open(writerObj);
    
    [d1, d2, d3] = size(tensor);
    
    for i=1:d3
        tempFrame = tensor(:,:,i);
        writeVideo(writerObj, tempFrame);
    end

    close(writerObj);

end