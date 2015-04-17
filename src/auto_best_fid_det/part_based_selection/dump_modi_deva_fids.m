function dump_modi_deva_fids(path, dataset)

    %
    addpath('deva/');
    load face_p99.mat;
    model.thresh = -1 * realmax;
    model.interval = 1;
    load([path '/' dataset '_data/facemap.mat']);
    load([path '/' dataset '_data/parts_heat_map.mat']);

    %
    if(dataset == 'lfpw')
        face_list = [812:1035]';
        all_face_list = [1:1035]';
    elseif(dataset == 'cofw')
        %face_list = [1346:1852]';
        face_list = [1346:1395]';
        all_face_list = [1:1852]';
    elseif(dataset == 'aflw')
        face_list = [1:2500]';
        all_face_list = [1:24386]'; 
    end
    number_of_samples = size(face_list, 1);
    modi_deva_fids = cell(size(all_face_list, 1), 1);

    %
    for i=1:number_of_samples
        
        disp([num2str(i) '/' num2str(number_of_samples) ' done']);
        
        face_num = face_list(i);

        im = imread(facemap{face_num});

        if(size(im,3)==1)
            deva_fids{i} = [];
            continue;
        end

        resp = parts_heat_map(face_num);
        
        bs = detect(im, model, model.thresh, resp);
        bs = clipboxes(im, bs);
        bs = nms_face(bs,0.3);

        if(~isempty(bs))
            modi_deva_fids{face_num} = bs(1);
        end

    end

    %
    save([path '/' dataset '_data/modi_deva_fids.mat'], 'modi_deva_fids');

end
