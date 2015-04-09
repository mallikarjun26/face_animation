function k_nearest_exem_plot(path, dataset, hog_sift)

    %
    clc; close all;

    addpath('../../util/');
    addpath(genpath('/home/mallikarjun/src/subtightplot'));
    subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);

    load([path '/' dataset '_data/facemap.mat']);
    load([path '/' dataset '_data/chehra_fids.mat']);
    load([path '/' dataset '_data/deva_fids.mat']);
    load([path '/' dataset '_data/intraface_fids.mat']);
    load([path '/' dataset '_data/rcpr_fids.mat']);
    load([path '/' dataset '_data/part_score.mat']);
    load([path '/' dataset '_data/k_near_exemplars.mat']);
    load([path '/' dataset '_data/ground_truth.mat']);
    load([path '/' dataset '_data/app_based_results/selected_models.mat']);
    load([path '/' dataset '_data/app_based_results/app_based_results.mat']);
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
    
%     load(['~/data/results/3_april/sift_hog_nearest_k/' hog_sift '_k_near_exemplars.mat']);
%     load(['~/data/results/3_april/sift_hog_nearest_k/' hog_sift '_selected_models.mat']);

    %
    if(dataset == 'lfpw')
        g_mode = 7;
    elseif(dataset == 'cofw')
        g_mode = 8;
    elseif(dataset == 'aflw')
        g_mode = 9;
    end

    %
    test_sample = [1346:1852]'; 
    num_of_samples = size(test_sample, 1);

    h=figure;
    for i=1:num_of_samples
        clf;
        test_sample_num = test_sample(i);
        subplot(1, 6, 1);
        im = imread(facemap{test_sample_num});
        imshow(im);
        hold on;

        switch(selected_models(test_sample_num)) 

            case 1
              fids = chehra_fids{test_sample_num};
              plot_chehra_fids(fids, im, 0, 0, 'b.');
            case 2
              fids = deva_fids{test_sample_num};
              plot_deva_fids(fids, im, 0, 0, 'b.');
            case 3
              fids = intraface_fids{test_sample_num};
              plot_intraface_fids(fids, im, 0, 0, 'b.');
            case 4
              fids = rcpr_fids{test_sample_num};
              plot_rcpr_fids(fids, im, 0, 0, 'b.');
        end

        sel_mod = selected_models(test_sample_num);
        k_near = k_near_exemplars(test_sample_num);
        k_near = k_near{sel_mod};

        %plot_exem_fids(selected_models(test_sample_num), k_near, part_score(test_sample_num), ground_truth, chehra_deva_intraface_rcpr_common_fids, facemap, g_mode);
        plot_exem_fids(k_near_exemplars, part_score(test_sample_num), ground_truth, chehra_deva_intraface_rcpr_common_fids, facemap, g_mode, test_sample_num, app_diff_min, chehra_fids, deva_fids, intraface_fids, rcpr_fids);

    %pause;
    saveas(h, ['~/data/results/3_april/sift_hog_nearest_k/' hog_sift '_nearest_k/' num2str(test_sample_num) '.jpg']);
    
    end

end

function plot_exem_fids( k_near_exemplars, exem_part_score, fids, chehra_deva_intraface_rcpr_common_fids, facemap, g_mode, test_sample_num, app_diff_min, chehra_fids, deva_fids, intraface_fids, rcpr_fids)

    num_of_parts = 20;
    col_code = cell(5,1);
    col_code{1} = 'b.'; col_code{2} = 'g.'; col_code{3} = 'c.'; col_code{4} = 'r.'; col_code{5} = 'k.';

    part_score_t = NaN * ones(5, 20);
    
    sel_mode_list = get_sel_mode_list(app_diff_min{test_sample_num});
    
    for i=1:4
        sel_mode = sel_mode_list(i);
        subplot(4, 6, ((i-1)*6)+1);
        im = imread(facemap{test_sample_num});
        imshow(im);
        hold on;
       
        switch(sel_mode) 

            case 1
              fids_t = chehra_fids{test_sample_num};
              plot_chehra_fids(fids_t, im, 0, 0, 'b.');
            case 2
              fids_t = deva_fids{test_sample_num};
              plot_deva_fids(fids_t, im, 0, 0, 'b.');
            case 3
              fids_t = intraface_fids{test_sample_num};
              plot_intraface_fids(fids_t, im, 0, 0, 'b.');
            case 4
              fids_t = rcpr_fids{test_sample_num};
              plot_rcpr_fids(fids_t, im, 0, 0, 'b.');
        end
        
        k_near = k_near_exemplars(test_sample_num);
        k_near = k_near{sel_mode};
        
        
        for j=1:5
            temp = exem_part_score(k_near(j)); 
            part_score_t(j,:) = temp(sel_mode, :); 
        end

        for j=1:20
            [~, part_score_t(:, j)] = sort(part_score_t(:,j));
        end

        for j=1:5
            subplot(4, 6, ((i-1)*6)+j+1);
            im = imread(facemap{k_near(j)});
            imshow(im);
            hold on;
            if(isempty(fids{k_near(j)}))
                continue;
            end

            fids_t = uint32(get_fid(fids{k_near(j)}, g_mode, chehra_deva_intraface_rcpr_common_fids));
            for k=1:20
                plot(fids_t(k,2), fids_t(k,1), col_code{part_score_t(j, k)}, 'MarkerSize', 12);
                hold on
            end
        end

    end
end

function sel_mode_list = get_sel_mode_list(app_min)
    t = [app_min.app_chehra; app_min.app_deva; app_min.app_intraface; app_min.app_rcpr;]; 
    [~, sel_mode_list] = sort(t);
end


% function plot_exem_fids(sel_mod, k_near, exem_part_score, fids, chehra_deva_intraface_rcpr_common_fids, facemap, g_mode)
% 
%     num_of_parts = 20;
%     col_code = cell(5,1);
%     col_code{1} = 'b.'; col_code{2} = 'g.'; col_code{3} = 'c.'; col_code{4} = 'r.'; col_code{5} = 'k.';
% 
%     part_score_t = NaN * ones(5, 20);
%     for j=1:5
%         temp = exem_part_score(k_near(j)); 
%         part_score_t(j,:) = temp(sel_mod, :); 
%     end
% 
%     for j=1:20
%         [~, part_score_t(:, j)] = sort(part_score_t(:,j));
%     end
% 
%     for j=1:5
%         subplot(1, 6, j+1);
%         im = imread(facemap{k_near(j)});
%         imshow(im);
%         hold on;
%         if(isempty(fids{k_near(j)}))
%             continue;
%         end
%         
%         fids_t = uint32(get_fid(fids{k_near(j)}, g_mode, chehra_deva_intraface_rcpr_common_fids));
%         for k=1:20
%             plot(fids_t(k,2), fids_t(k,1), col_code{part_score_t(j, k)}, 'MarkerSize', 12);
%             hold on
%         end
%     end
% 
% end


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
