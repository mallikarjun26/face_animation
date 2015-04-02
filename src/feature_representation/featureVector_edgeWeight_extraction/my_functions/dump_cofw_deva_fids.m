function dump_cofw_deva_fids(path)

    %
    clc; close all;

    %
    addpath('./../');
    load([path '/cofw_data/facemap.mat']);
    load face_p99.mat
    model.interval = 5;
    %model.thresh = min(-0.65, model.thresh);
    model.thresh = realmin; 

    %
    number_of_faces = size(facemap,2);
    deva_fids = cell(number_of_faces, 1);

    %
    for i=1:number_of_faces

        if(mod(i,5)==0)
            disp([num2str(i) '/' num2str(number_of_faces) ' done']);
        end

        im = imread(facemap{i});

        if(size(im,3)==1)
            deva_fids{i} = [];
            continue;
        end

        bs = detect(im, model, model.thresh);
        bs = clipboxes(im, bs);
        bs = nms_face(bs,0.3);

        if(~isempty(bs))
            deva_fids{i} = bs(1);
        else
            deva_fids{i} = [];
        end

    end

    %
    save([path '/cofw_data/deva_fids.mat'], 'deva_fids');

end
