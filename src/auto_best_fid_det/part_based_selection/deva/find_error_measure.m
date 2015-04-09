function [err_measure, deva_bbs, global_model_map, global_fiducials] = find_error_measure(path, number_of_samples)

    %
    load([path '/belhumeur_data/intermediate_results/global_fiducials.mat']);
    load([path '/belhumeur_data/intermediate_results/global_model_map.mat']);
    posemap = 90:-15:-90;
    load('face_p99.mat');
    model.thresh = -0.65;
    
    %
    %number_of_samples = size(global_fiducials,1);
    common_parts = get_common_parts(path);
    err_measure = zeros(number_of_samples, 1);
    deva_bbs = cell(number_of_samples,1);
    
    %
    for i=1:number_of_samples
       
        disp(['Error measure for ' num2str(i) '/' num2str(number_of_samples) ' samples']);
        
        im = imread(global_model_map{i,1});
        
        if(size(im,3) ~= 3)
            deva_bbs{i,1} = [];
            continue;
        end
        
        [bs, resp, components] = detect(im, model, model.thresh);
        bs = clipboxes(im, bs);
        bs = nms_face(bs,0.3);

        if(isempty(bs))
            deva_bbs{i,1} = [];
            continue;
        end
        if( (bs(1).c < 4) || (bs(1).c > 10) )
            deva_bbs{i,1} = [];
            continue; 
        end
        
        deva_bbs{i,1} = bs(1);
        
        err_measure(i,1) = get_error(bs(1), global_fiducials{i,1}, common_parts);
    end
    
    save([path '/error_measures/deva_bbs.mat'], 'deva_bbs');
    save([path '/error_measures/deva_errors.mat'], 'err_measure');
    
end


function err = get_error(bd, bt, common_parts)

    num_of_com_parts = size(common_parts,1);
    deva_fids = [uint32((bd.xy(:,2)+bd.xy(:,4))/2) uint32((bd.xy(:,1)+bd.xy(:,3))/2)];
    tru_fids  = bt;
    
    t1 = [deva_fids(common_parts(:,1),1)' deva_fids(common_parts(:,1),2)'];
    t2 = [tru_fids(common_parts(:,2),1)' tru_fids(common_parts(:,2),2)'];
    t = double([t1;t2]);
    
    err = pdist(t) / num_of_com_parts;
end

function common_parts = get_common_parts(path)

    fid = fopen([path '/belhumeur_data/map_files']);
    temp_c = textscan(fid, '%u %u', 'HeaderLines', 1);
    common_parts = [];
    common_parts = temp_c{1};
    common_parts = [common_parts temp_c{1,2}];

end