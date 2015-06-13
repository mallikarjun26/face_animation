function show_comparision(dataset, sample, cdir)

    %
    load(['~/Documents/data/iccv/' dataset '_data/chehra_fids.mat']);
    load(['~/Documents/data/iccv/' dataset '_data/deva_fids.mat']);
    load(['~/Documents/data/iccv/' dataset '_data/intraface_fids.mat']);
    load(['~/Documents/data/iccv/' dataset '_data/rcpr_fids.mat']);
    load(['~/Documents/data/iccv/' dataset '_data/facemap.mat']);
    load('~/Documents/data/iccv/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat');
    addpath('../util');

    %
    im = imread(facemap{sample});

    h = figure;

    fids_c = chehra_fids{sample};
    [fids_c] = get_fid(fids_c, 1, chehra_deva_intraface_rcpr_common_fids);
    subplot(1,5,1);
    plot_chehra_fids(fids_c, im, 1, 0, 'r.');

    fids_d = deva_fids{sample};
    [fids_d] = get_fid(fids_d, 2, chehra_deva_intraface_rcpr_common_fids);
    subplot(1,5,2);
    plot_chehra_fids(fids_d, im, 1, 0, 'g.');

    fids_i = intraface_fids{sample};
    [fids_i] = get_fid(fids_i, 3, chehra_deva_intraface_rcpr_common_fids);
    subplot(1,5,3);
    plot_chehra_fids(fids_i, im, 1, 0, 'b.');

    fids_r = rcpr_fids{sample};
    [fids_r] = get_fid(fids_r, 4, chehra_deva_intraface_rcpr_common_fids);
    subplot(1,5,4);
    plot_chehra_fids(fids_r, im, 1, 0, 'c.');
    
    subplot(1,5,5);
    show_our(fids_c, fids_d, fids_i, fids_r, cdir, im) 

    saveas(h, ['/home/mallikarjun/Documents/data/iccv/results/mrf_min/' dataset '/' num2str(sample) '.jpg']);
    
end

function show_our(fids_c, fids_d, fids_i, fids_r, cdir, im) 

    imshow(im);
    hold on;
    
    temp = find(cdir==1); 
    temp = [fids_c(temp,1) fids_c(temp,2)];
    plot(temp(:,2),temp(:,1), 'r.')

    temp = find(cdir==2); 
    temp = [fids_d(temp,1) fids_d(temp,2)];
    plot(temp(:,2),temp(:,1), 'g.')

    temp = find(cdir==3); 
    temp = [fids_i(temp,1) fids_i(temp,2)];
    plot(temp(:,2),temp(:,1), 'b.')

    temp = find(cdir==4); 
    temp = [fids_r(temp,1) fids_r(temp,2)];
    plot(temp(:,2),temp(:,1), 'c.')

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
