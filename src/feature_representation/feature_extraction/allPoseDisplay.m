function bs = allPoseDisplay(inputPath)

    load face_p99.mat;
    posemap = 90:-15:-90;
    im = imread(inputPath);
    
    %clf; imagesc(im); axis image; axis off; drawnow;
    
    tic;
    bs = detect(im, model, -1);
    bs = clipboxes(im, bs);
    bs = nms_face(bs,0.3);
    dettime = toc;
    
    % show highest scoring one
    figure,showboxes(im, bs(1),posemap),title('Highest scoring detection');
    % show all
   % figure,showboxes(im, bs,posemap),title('All detections above the threshold');
    
    fprintf('Detection took %.1f seconds\n',dettime);
    disp('press any key to continue');
    
end