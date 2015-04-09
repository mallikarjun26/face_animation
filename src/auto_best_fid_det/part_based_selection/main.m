function [im, heat_map] = main(path, dataset)

    %
    clc; close all;
    
    %
    run('/home/mallikarjun/src/vlfeat/vlfeat-0.9.19/toolbox/vl_setup')

    %
    load([path '/' dataset '_data/facemap.mat']);
    load([path '/' dataset '_data/chehra_fids.mat']);
    load([path '/' dataset '_data/deva_fids.mat']);
    load([path '/' dataset '_data/intraface_fids.mat']);
    load([path '/' dataset '_data/rcpr_fids.mat']);
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
    load([path '/' dataset '_data/app_based_results/selected_models.mat']);
    load([path '/' dataset '_data/app_based_results/chehra_app_vector.mat']);
    load([path '/' dataset '_data/app_based_results/deva_app_vector.mat']);
    load([path '/' dataset '_data/app_based_results/intraface_app_vector.mat']);
    load([path '/' dataset '_data/app_based_results/rcpr_app_vector.mat']);

    %
    sample_num = 1500 ;

    im = imread(facemap{sample_num});
    if(size(im,3)==3)
        im = single(rgb2gray(im));
    else
        im = single(im);
    end
    chehra_fids_t        = get_fid(chehra_fids{sample_num}, 1, chehra_deva_intraface_rcpr_common_fids);
    deva_fids_t          = get_fid(deva_fids{sample_num}, 2, chehra_deva_intraface_rcpr_common_fids);
    intraface_fids_t     = get_fid(intraface_fids{sample_num}, 3, chehra_deva_intraface_rcpr_common_fids);
    rcpr_fids_t          = get_fid(rcpr_fids{sample_num}, 4, chehra_deva_intraface_rcpr_common_fids);

    %
    heat_map = cell(20, 1);

    for i=1:20
        feat_rf = cell(4,1);
        %feat_rf = get_feat_rf(chehra_app_vector, deva_app_vector, intraface_app_vector, rcpr_app_vector, selected_models, sample_num);
        feat_rf{1} = chehra_app_vector{sample_num}{i};
        feat_rf{2} = deva_app_vector{sample_num}{i};
        feat_rf{3} = intraface_app_vector{sample_num}{i};
        feat_rf{4} = rcpr_app_vector{sample_num}{i};
        heat_map{i} = get_heat_map(chehra_fids_t(i,:), deva_fids_t(i,:), intraface_fids_t(i,:), rcpr_fids_t(i,:), im, feat_rf);
    end
    save('results/heat_map.mat', 'heat_map');

end

function feat_rf = get_feat_rf(chehra_app_vector, deva_app_vector, intraface_app_vector, rcpr_app_vector, selected_models, sample_num)

    switch(selected_models(sample_num))

        case 1 
            feat_rf = chehra_app_vector{sample_num};
        case 2 
            feat_rf = deva_app_vector{sample_num};
        case 3 
            feat_rf = intraface_app_vector{sample_num};
        case 4 
            feat_rf = rcpr_app_vector{sample_num};
    
    end
end


function [fid_o] = get_fid(fid, fid_mode, chehra_deva_intraface_rcpr_common_fids)

    if(fid_mode == 2)
        
        fid_mode_u = 0;
        if( (fid.c>3) && (fid.c<11) )
            fid_mode_u = 2;
        elseif(fid.c>10)
            fid_mode_u = 6;
        else
            fid_mode_u = 5;
        end
        
        
        y = NaN * ones(size(chehra_deva_intraface_rcpr_common_fids,1), 1);
        x = y;
        for i=1:size(chehra_deva_intraface_rcpr_common_fids,1)
            index = chehra_deva_intraface_rcpr_common_fids(i, fid_mode_u);
            if(~isnan(index))
                y(i,1) = uint32((fid.xy(index,2) + fid.xy(index,4)) / 2);
                x(i,1) = uint32((fid.xy(index,1) + fid.xy(index,3)) / 2);
            end
        end
        
        fid_o = ([y x]);
    else
        number_of_parts = size(chehra_deva_intraface_rcpr_common_fids, 1);
        
        y = NaN * ones(size(chehra_deva_intraface_rcpr_common_fids,1), 1);
        x = y;
        for i=1:number_of_parts
            index = chehra_deva_intraface_rcpr_common_fids(i,fid_mode);
            if(~isnan(index))
                y(i,1) = fid(index, 1);
                x(i,1) = fid(index, 2);
            end
        end
        fid_o = ([y x]);
        
%         y = fid(chehra_deva_intraface_rcpr_common_fids(:,fid_mode),1);
%         x = fid(chehra_deva_intraface_rcpr_common_fids(:,fid_mode),2);
%         fid_o = ([y x]);
    end

end
