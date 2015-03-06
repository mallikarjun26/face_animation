function [shape_diff, app_diff_avg, app_diff_min] = main(path, input_image_num_list)

    %
    clc;
    run('/home/mallikarjun/src/vlfeat/vlfeat-0.9.19/toolbox/vl_setup')
    
    %
    load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
    load([path '/chehra_data/intermediate_results/chehra_fids.mat']);
    load([path '/deva_data/intermediate_results/deva_fids.mat']);
    load([path '/intraface_data/intermediate_results/intraface_fids.mat']);
    load([path '/rcpr_data/intermediate_results/rcpr_fids.mat']);
    load([path '/Faces5000/intermediate_results/facemap.mat']);

    %
    show_fitting_enable = 0;
    %input_image_num_list = [3852; 1438; 4678; 4093; 3852; 3927; 3437; 4522; 1590; 10; 21; 28; 34; 42; 43; 45; 503; 822; 1238; 1640];
    sim_image_num_list   = [1; 2; 4; 5; 6; 7; 8; 9; 11; 12; 13; 15; 16; 17; 18; 19; 20; 22; 23; 27; 32; 33];

    shape_diff = cell(size(input_image_num_list,1),1);
    app_diff_avg = cell(size(input_image_num_list,1),1  );
    app_diff_min = cell(size(input_image_num_list,1),1  );
    
    for i=1:size(input_image_num_list,1)

        tic;
        disp([num2str(i) '/' num2str(size(input_image_num_list,1)) ' running']);

        input_image_num = input_image_num_list(i);
        
        s_chehra_fid    = chehra_fids{input_image_num};
        s_deva_fid      = deva_fids{input_image_num};
        s_rcpr_fid      = rcpr_fids{input_image_num};
        s_intraface_fid      = intraface_fids{input_image_num};
        input_image     = imread(facemap{input_image_num});

        %
        if(isempty(s_deva_fid))
            s_deva_fid.xy = ones(68,4);
        elseif(size(s_deva_fid.xy,1) ~=68)
            s_deva_fid.xy = ones(68,4);
        end
        if(isempty(s_intraface_fid))
            s_intraface_fid = ones(49,2);
        end
        if(isempty(s_rcpr_fid))
            s_rcpr_fid = ones(29,2);
        end
        if(isempty(s_chehra_fid))
            s_chehra_fid = ones(49,2);
        end
        
        %
        [shape_chehra_deva_t, shape_chehra_rcpr_t, shape_deva_rcpr_t, shape_chehra_intraface_t, shape_deva_intraface_t, shape_intraface_rcpr_t] = get_shape_similarity(s_chehra_fid, s_deva_fid, s_intraface_fid, s_rcpr_fid, chehra_deva_intraface_rcpr_common_fids);

        shape_diff_t.shape_chehra_deva = shape_chehra_deva_t;
        shape_diff_t.shape_chehra_rcpr = shape_chehra_rcpr_t;
        shape_diff_t.shape_deva_rcpr   = shape_deva_rcpr_t; 
        shape_diff_t.shape_chehra_intraface = shape_chehra_intraface_t; 
        shape_diff_t.shape_deva_intraface = shape_deva_intraface_t; 
        shape_diff_t.shape_intraface_rcpr = shape_intraface_rcpr_t;

        app_chehra = 0;
        app_deva   = 0;
        app_intraface = 0;
        app_rcpr = 0;
        
        app_chehra_min = realmax;
        app_deva_min   = realmax;
        app_intraface_min = realmax;
        app_rcpr_min = realmax;
        
        for j=1:size(sim_image_num_list,1)
            disp(['    ' num2str(j) '/' num2str(size(sim_image_num_list,1)) ' running']);
            sim_image_num = sim_image_num_list(j);
            sim_fid         = chehra_fids{sim_image_num};
            sim_image       = imread(facemap{sim_image_num});

            if(show_fitting_enable)
                show_fitting(s_chehra_fid, s_deva_fid, s_intraface_fid, s_rcpr_fid, input_image, sim_fid, sim_image);
            end

            %
            [app_chehra_t, app_deva_t, app_intraface_t, app_rcpr_t] = get_appearance_similarity(s_chehra_fid, s_deva_fid, s_intraface_fid, s_rcpr_fid, input_image, sim_image, sim_fid, 1, chehra_deva_intraface_rcpr_common_fids);
            app_chehra = app_chehra + app_chehra_t;
            app_deva = app_deva + app_deva_t;
            app_intraface = app_intraface + app_intraface_t;
            app_rcpr = app_rcpr + app_rcpr_t;
            
            if(app_chehra_min> app_chehra_t)
                app_chehra_min = app_chehra_t;
            end
            
            if(app_deva_min> app_deva_t)
                app_deva_min = app_deva_t;
            end
            
            if(app_intraface_min> app_intraface_t)
                app_intraface_min = app_intraface_t;
            end
            
            if(app_rcpr_min> app_rcpr_t)
                app_rcpr_min = app_rcpr_t;
            end
        end
        
        
        app_diff_avg_t.app_chehra = app_chehra / size(input_image_num_list,1); 
        app_diff_avg_t.app_deva = app_deva / size(input_image_num_list,1); 
        app_diff_avg_t.app_intraface = app_intraface / size(input_image_num_list,1); 
        app_diff_avg_t.app_rcpr = app_rcpr / size(input_image_num_list,1); 

        app_diff_min_t.app_chehra = app_chehra_min ; 
        app_diff_min_t.app_deva = app_deva_min ; 
        app_diff_min_t.app_intraface = app_intraface_min ; 
        app_diff_min_t.app_rcpr = app_rcpr_min ; 
        
        shape_diff{i} = shape_diff_t;
        app_diff_avg{i} = app_diff_avg_t;
        app_diff_min{i} = app_diff_min_t;

        disp(['Time taken ' num2str(toc)]);
    end

end

function show_fitting(s_chehra_fid, s_deva_fid, s_intraface_fid, s_rcpr_fid, input_image, sim_fid, sim_image)

    figure;
    subplot();

end

function [shape_chehra_deva, shape_chehra_rcpr, shape_deva_rcpr, shape_chehra_intraface, shape_deva_intraface, shape_intraface_rcpr] = get_shape_similarity(s_chehra_fid, s_deva_fid, s_intraface_fid, s_rcpr_fid, chehra_deva_intraface_rcpr_common_fids)

    % TODO: Make it scale and translation invariant    

    %
    number_of_common_parts = size(chehra_deva_intraface_rcpr_common_fids,1);
    t1 = double([ s_chehra_fid(chehra_deva_intraface_rcpr_common_fids(:,1),1)' s_chehra_fid(chehra_deva_intraface_rcpr_common_fids(:,1),2)' ]);
    x = (s_deva_fid.xy(:,1) + s_deva_fid.xy(:,3) ) / 2 ;
    y = (s_deva_fid.xy(:,2) + s_deva_fid.xy(:,4) ) / 2 ;
    t2 = double([y(chehra_deva_intraface_rcpr_common_fids(:,2),1)' x(chehra_deva_intraface_rcpr_common_fids(:,2),1)' ]);
    t3 = double([ s_intraface_fid(chehra_deva_intraface_rcpr_common_fids(:,3),1)' s_intraface_fid(chehra_deva_intraface_rcpr_common_fids(:,3),2)' ]);
    t4 = double([ s_rcpr_fid(chehra_deva_intraface_rcpr_common_fids(:,4),1)' s_rcpr_fid(chehra_deva_intraface_rcpr_common_fids(:,4),2)' ]);
    
    
    t = [t1 ; t2];
    shape_chehra_deva = pdist(t) / number_of_common_parts;
    
    t = [t1 ; t4];
    shape_chehra_rcpr = pdist(t) / number_of_common_parts;
    
    t = [t2 ; t4];
    shape_deva_rcpr = pdist(t) / number_of_common_parts;

    t = [t1 ; t3];
    shape_chehra_intraface = pdist(t) / number_of_common_parts;

    t = [t2 ; t3];
    shape_deva_intraface = pdist(t) / number_of_common_parts;

    t = [t3 ; t4];
    shape_intraface_rcpr = pdist(t) / number_of_common_parts;
    
    
end

function [app_chehra, app_deva, app_intraface, app_rcpr] = get_appearance_similarity(s_chehra_fid, s_deva_fid, s_intraface_fid, s_rcpr_fid, input_image, sim_image, sim_fid, sim_model, chehra_deva_intraface_rcpr_common_fids)

    %
    [fid_1] = get_fid(s_chehra_fid, 1, chehra_deva_intraface_rcpr_common_fids);
    [fid_2] = get_fid(s_deva_fid, 2, chehra_deva_intraface_rcpr_common_fids);
    [fid_3] = get_fid(s_intraface_fid, 3, chehra_deva_intraface_rcpr_common_fids);
    [fid_4] = get_fid(s_rcpr_fid, 4, chehra_deva_intraface_rcpr_common_fids);
    [fid_t] = get_fid(sim_fid, sim_model, chehra_deva_intraface_rcpr_common_fids);
    
    %
    app_chehra = get_sift_hog_similarity(input_image, fid_1, sim_image, fid_t);
    app_deva = get_sift_hog_similarity(input_image, fid_2, sim_image, fid_t);
    app_intraface = get_sift_hog_similarity(input_image, fid_3, sim_image, fid_t);
    app_rcpr = get_sift_hog_similarity(input_image, fid_4, sim_image, fid_t);
    
    
end

function [fid] = get_fid(fid, fid_mode, chehra_deva_intraface_rcpr_common_fids)

    if(fid_mode == 2)
        y = uint32((fid.xy(chehra_deva_intraface_rcpr_common_fids(:,3),2) + fid.xy(chehra_deva_intraface_rcpr_common_fids(:,3),4)) / 2);
        x = uint32((fid.xy(chehra_deva_intraface_rcpr_common_fids(:,3),1) + fid.xy(chehra_deva_intraface_rcpr_common_fids(:,3),3)) / 2);
        fid = [y x];
    else
        y = fid(chehra_deva_intraface_rcpr_common_fids(:,fid_mode),1);
        x = fid(chehra_deva_intraface_rcpr_common_fids(:,fid_mode),2);
        fid = [y x];
    end

end

function [app_measure]= get_sift_hog_similarity(im_1, fid_1, im_2, fid_2)

    %
    im_1 = single(rgb2gray(im_1));
    im_2 = single(rgb2gray(im_2));
    number_of_parts = size(fid_1,1);

    %
    number_of_scales = 2;
    scales_1 = zeros(number_of_scales, 1);
    scales_2 = zeros(number_of_scales, 1);
    scale_weights = zeros(number_of_scales, 1);
    
    left_eye = fid_1(11,:);
    right_eye = fid_1(14,:);
    inter_ocular_distance_1 = pdist(double([left_eye;right_eye]));
    left_eye = fid_2(11,:);
    right_eye = fid_2(14,:);
    inter_ocular_distance_2 = pdist(double([left_eye;right_eye]));
    
    for i=1:number_of_scales
        scale_weights(i,1) = 1/i;
        scales_1(i,1) = uint16(inter_ocular_distance_1/25)+(i*4);
        scales_2(i,1) = uint16(inter_ocular_distance_2/25)+(i*4);
    end
    
    %
    sift_similarity = 0;
    hog_similarity = 0;
    for i=1:number_of_parts
        
        x_1 = fid_1(i,2);
        y_1 = fid_1(i,1);

        x_2 = fid_2(i,2);
        y_2 = fid_2(i,1);
        
        hog_similarity = hog_similarity + get_hog_similarity(im_1, x_1, y_1, im_2, x_2, y_2);
        
        for j=1:number_of_scales
            
            fc_1 = double([x_1; y_1; scales_1(j); 0]);
            [~, sift_1] = vl_sift(im_1,'frames',fc_1) ;

            
            fc_2 = double([x_2; y_2; scales_2(j); 0]);
            [~, sift_2] = vl_sift(im_2,'frames',fc_2) ;
        
            t_sim = pdist(double([sift_1';sift_2']));
            sift_similarity = sift_similarity + t_sim;
        end

    end
    
    sift_similarity = sift_similarity / (number_of_parts*number_of_scales);
    hog_similarity = hog_similarity / number_of_parts;
    app_measure = sift_similarity + hog_similarity;
end

function hog_similarity = get_hog_similarity(im_1, x_1, y_1, im_2, x_2, y_2)
    
    im_size_1 = size(im_1);
    x1 = uint32(max(x_1 - (im_size_1(1,2)*0.015),1)); 
    x2 = uint32(min(x_1 + (im_size_1(1,2)*0.015), im_size_1(1,2))); 
    y1 = uint32(max(y_1 - (im_size_1(1,1)*0.015),1)); 
    y2 = uint32(min(y_1 + (im_size_1(1,1)*0.015), im_size_1(1,1))); 
   
    if( (x1>=x2) || (y1>=y2) )
        %disp('Debug 1');
        x1 = im_size_1(1,2);
        x2 = x1;
        y1 = im_size_1(1,1);
        y2 = y1;
    end
    im_part_1 = im_1(y1:y2, x1:x2);
    
    im_size_2 = size(im_2);
    x1 = uint32(max(x_2 - uint32(im_size_2(1,2)*0.015),1)); 
    x2 = uint32(min(x_2 + uint32(im_size_2(1,2)*0.015), im_size_2(1,2))); 
    y1 = uint32(max(y_2 - uint32(im_size_2(1,1)*0.015),1)); 
    y2 = uint32(min(y_2 + uint32(im_size_2(1,1)*0.015), im_size_2(1,1))); 
 
    if( (x1>=x2) || (y1>=y2) )
        %disp('Debug 1');
        x1 = im_size_1(1,2);
        x2 = x1;
        y1 = im_size_1(1,1);
        y2 = y1;
    end
    im_part_2 = im_2(y1:y2, x1:x2);
    
    if( (x1>=x2) || (y1>=y2) )
        disp('Debug 1');
    end
    
    if(size(im_part_1) ~= size(im_part_2))
        im_part_1 = imresize(im_part_1, [10 10]);
        im_part_2 = imresize(im_part_2, [10 10]);
    end

    hog_1 = vl_hog(im_part_1, 3);
    hog_2 = vl_hog(im_part_2, 3);
    hog_1 = reshape(hog_1, [1,size(hog_1(:))]);
    hog_2 = reshape(hog_2, [1,size(hog_2(:))]);
    
    hog_similarity = pdist([hog_1; hog_2]);
end

function im_part = get_im_part(im, fid_pt)

    y1 = max(fid_pt(1,1) - 5, 1);
    x1 = max(fid_pt(1,2) - 5, 1);
    y2 = min(fid_pt(1,1) + 5, size(im,1));
    x2 = min(fid_pt(1,2) + 5, size(im,2));
    im_part = im(y1:y2, x1:x2);
    im_part = imresize(im_part, [10 10]);
        
end

