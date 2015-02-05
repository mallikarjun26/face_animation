function dump_features(input_path)

    % Load mat files
    load('face_p99.mat')
    load([input_path '/intermediate_results/facemap.mat']);
    
    % Initialize variables
    number_of_nodes = size(facemap,2);
    
    appearance_features = cell(number_of_nodes, 1);
    model.thresh = min(-0.65, model.thresh); 
    model.interval = 5;
    posemap = 90:-15:-90;
    
    
    %%
    disp('Computing bounding boxes for fiducial points..');
    bounding_boxes = get_bb(facemap, model, input_path);
    
    disp('Computing appearance features for fiducial parts in all faces..')
    for i = 1 : number_of_nodes
        
       if(mod(i,10) == 0)
            disp([num2str(i) '/' num2str(number_of_nodes) 'nodes done']); 
       end
       
       %
       im = imread(facemap{1,i});
       
       %
       im = rgb2gray(im);
       appearance_features{i, 1} = get_feat(im, bounding_boxes{i, 1});
       
    end
    
    %
    save([input_path '/intermediate_results/appearance_features.mat'], 'appearance_features');

end

function bounding_boxes = get_bb(facemap, model, input_path)

    %
    if( exist([input_path '/intermediate_results/bounding_boxes.mat']) ~= 0)
        load([input_path '/intermediate_results/bounding_boxes.mat']);
        return;
    end

    %    
    number_of_nodes = size(facemap,2);
    bounding_boxes = cell(number_of_nodes, 1);
    
    %
    for i = 1 : number_of_nodes
        
       if(mod(i,10) == 0)
            disp([num2str(i) '/' num2str(number_of_nodes) ' bbs done']); 
       end
       
       %
       im = imread(facemap{1,i});

       %
       bs = detect(im, model, model.thresh);
       bs = clipboxes(im, bs);
       bs = nms_face(bs,0.3);

       if(isempty(bs) == 0)
           bounding_boxes{i, 1} = bs(1);
       else
           bounding_boxes{i, 1} = [];
       end
       
       
    end
    
    save([input_path '/intermediate_results/bounding_boxes.mat'], 'bounding_boxes');
    
end

function feat = get_feat(im, bs)

    %
    if(isempty(bs) == 1)
        feat = [];
        return;
    end
    %
    part_size = [20 20];
    lbp_cell_size = 7;
    lbp_feat_size = 2 * 2 * 58;
    number_of_components = size(bs.xy, 1);
    field_1 = 'c';
    field_2 = 'feat';
    value_1 = bs.c;
    value_2 = zeros(number_of_components, lbp_feat_size);
    
    %
    for i = 1 : number_of_components
        im_part = im(uint32(bs.xy(i,1):bs.xy(i,3)), uint32(bs.xy(i,2):bs.xy(i,4))); 
        im_part = single(imresize(im, part_size));
        value_2(i,:) = reshape( vl_lbp(im_part, lbp_cell_size) , 1 , lbp_feat_size);
    end
    
    feat = struct(field_1, value_1, field_2, value_2);
    
end
