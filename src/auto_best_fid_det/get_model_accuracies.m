function [chehra_accuracy, deva_accuracy, intraface_accuracy, rcpr_accuracy, our_model_accuracy] = get_model_accuracies(path, face_list, dataset, per_part_error_threshold, auto_train_select)

    %
    if(dataset == 'jack')
        load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
        load([path '/chehra_data/intermediate_results/chehra_fids.mat']);
        load([path '/deva_data/intermediate_results/deva_fids.mat']);
        load([path '/intraface_data/intermediate_results/intraface_fids.mat']);
        load([path '/rcpr_data/intermediate_results/rcpr_fids.mat']);
        load([path '/Faces5000/intermediate_results/facemap.mat']);
    else
        load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
        load([path '/' dataset '_data/chehra_fids.mat']);
        load([path '/' dataset '_data/deva_fids.mat']);
        load([path '/' dataset '_data/intraface_fids.mat']);
        load([path '/' dataset '_data/rcpr_fids.mat']);
        load([path '/' dataset '_data/ground_truth.mat']);
        load([path '/' dataset '_data/facemap.mat']);
        load([path '/' dataset '_data/ground_truth.mat']);
    end
    
    %
    number_of_faces = size(face_list,1);
    chehra_model_results = zeros(number_of_faces, 1);
    deva_model_results = zeros(number_of_faces, 1);
    intraface_model_results = zeros(number_of_faces, 1);
    rcpr_model_results = zeros(number_of_faces, 1);

    %
    for i=1:number_of_faces
   
        index = face_list(i);
        s_chehra_fid    = chehra_fids{index};
        s_deva_fid      = deva_fids{index};
        s_rcpr_fid      = rcpr_fids{index};
        s_intraface_fid      = intraface_fids{index};
        s_ground_truth_fid   = ground_truth{index}; 

        %
        if(isempty(s_deva_fid))
            s_deva_fid.xy = ones(68,4);
            s_deva_fid.c = 7;
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
        [s_chehra_fid] = get_fid(s_chehra_fid, 1, chehra_deva_intraface_rcpr_common_fids);
        [s_deva_fid] = get_fid(s_deva_fid, 2, chehra_deva_intraface_rcpr_common_fids);
        [s_intraface_fid] = get_fid(s_intraface_fid, 3, chehra_deva_intraface_rcpr_common_fids);
        [s_rcpr_fid] = get_fid(s_rcpr_fid, 4, chehra_deva_intraface_rcpr_common_fids);
        if(dataset == 'lfpw')
            [s_ground_truth_fid] = get_fid(s_ground_truth_fid, 7, chehra_deva_intraface_rcpr_common_fids);
        elseif(dataset == 'cofw')
            [s_ground_truth_fid] = get_fid(s_ground_truth_fid, 8, chehra_deva_intraface_rcpr_common_fids);
        elseif(dataset == 'aflw')
            [s_ground_truth_fid] = get_fid(s_ground_truth_fid, 9, chehra_deva_intraface_rcpr_common_fids);
        end

        %
        [chehra_model_results(i) deva_model_results(i) intraface_model_results(i) rcpr_model_results(i)] = check_accuracy(s_chehra_fid, s_deva_fid, s_intraface_fid, s_rcpr_fid, s_ground_truth_fid, per_part_error_threshold, index); 
    end

    selected_models = get_best_model(path, dataset, auto_train_select);

    [chehra_accuracy, deva_accuracy, intraface_accuracy, rcpr_accuracy, our_model_accuracy] = get_percentages(chehra_model_results, deva_model_results, intraface_model_results, rcpr_model_results, selected_models, face_list); 


end

function[chehra_accuracy, deva_accuracy, intraface_accuracy, rcpr_accuracy, our_model_accuracy] = get_percentages(chehra_model_results, deva_model_results, intraface_model_results, rcpr_model_results, selected_models, face_list)
    
    %
    number_of_faces = size(chehra_model_results, 1);

    %
    chehra_accuracy = ( size(find(chehra_model_results(:)),1) / number_of_faces ) * 100;
    deva_accuracy = ( size(find(deva_model_results(:)),1) / number_of_faces ) * 100;
    intraface_accuracy = ( size(find(intraface_model_results(:)),1) / number_of_faces ) * 100;
    rcpr_accuracy = ( size(find(rcpr_model_results(:)),1) / number_of_faces ) * 100;

    our_model_accuracy = 0;
    for i=1:number_of_faces

        index = face_list(i);

        switch selected_models(index)

            case 1
                if(chehra_model_results(i)==1)
                    our_model_accuracy = our_model_accuracy + 1; 
                end
            case 2
                if(deva_model_results(i)==1)
                    our_model_accuracy = our_model_accuracy + 1; 
                end
            case 3
                if(intraface_model_results(i)==1)
                    our_model_accuracy = our_model_accuracy + 1; 
                end
            case 4
                if(rcpr_model_results(i)==1)
                    our_model_accuracy = our_model_accuracy + 1; 
                end
        end
    end
    our_model_accuracy = (our_model_accuracy / number_of_faces) * 100;

end

function shape_dist = get_shape_dist(fid_1, fid_2)
    
    non_nan_1 = find(~isnan(fid_1(:,1)));
    non_nan_2 = find(~isnan(fid_2(:,1)));
    non_nan = intersect(non_nan_1, non_nan_2);

    shape_1 = [fid_1(non_nan,1)' fid_1(non_nan,2)'];
    shape_2 = [fid_2(non_nan,1)' fid_2(non_nan,2)'];

    shape_dist = pdist([shape_1; shape_2]);
    shape_dist = shape_dist / size(non_nan,1);
end

function [chehra_model_results deva_model_results intraface_model_results rcpr_model_results] = check_accuracy(s_chehra_fid, s_deva_fid, s_intraface_fid, s_rcpr_fid, s_ground_truth_fid, per_part_error_threshold, index)

    number_of_parts = size(s_ground_truth_fid,1);

    % t_gt = double([s_ground_truth_fid(:,1)' s_ground_truth_fid(:,2)']); 
    % t_1 =  double([s_chehra_fid(:,1)' s_chehra_fid(:,2)']); 
    % t_2 =  double([s_deva_fid(:,1)' s_deva_fid(:,2)']); 
    % t_3 =  double([s_intraface_fid(:,1)' s_intraface_fid(:,2)']); 
    % t_4 =  double([s_rcpr_fid(:,1)' s_rcpr_fid(:,2)']); 

    % chehra_shape_dist = pdist([t_gt; t_1]) / number_of_parts;
    % deva_shape_dist = pdist([t_gt; t_2]) / number_of_parts;
    % intraface_shape_dist = pdist([t_gt; t_3]) / number_of_parts;
    % rcpr_shape_dist = pdist([t_gt; t_4]) / number_of_parts;
    
    chehra_shape_dist = get_shape_dist(s_chehra_fid, s_ground_truth_fid);
    deva_shape_dist = get_shape_dist(s_deva_fid, s_ground_truth_fid);
    intraface_shape_dist = get_shape_dist(s_intraface_fid, s_ground_truth_fid);
    rcpr_shape_dist = get_shape_dist(s_rcpr_fid, s_ground_truth_fid);

    if(chehra_shape_dist < per_part_error_threshold)
        chehra_model_results = 1;
    else
        chehra_model_results = 0;
    end

    if(deva_shape_dist  < per_part_error_threshold)
        deva_model_results = 1;
    else
        deva_model_results = 0;
    end

    if(intraface_shape_dist < per_part_error_threshold)
        intraface_model_results = 1;
    else
        intraface_model_results = 0;
    end

    if(rcpr_shape_dist < per_part_error_threshold)
        rcpr_model_results = 1;
    else
        rcpr_model_results = 0;
    end
    
%     addpath ../util/;
%     comp_models('~/data/face_animation', [index], 'aflw', 1);
end


function [fid_o] = get_fid(fid, fid_mode, chehra_deva_intraface_rcpr_common_fids)

    if((fid_mode == 2) || (fid_mode == 5) || (fid_mode == 6) )
        
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
        y = NaN * ones(size(chehra_deva_intraface_rcpr_common_fids,1), 1);
        x = y;
        for i=1:size(chehra_deva_intraface_rcpr_common_fids,1)
            index = chehra_deva_intraface_rcpr_common_fids(i, fid_mode);
            if(~isnan(index))
                y(i,1) = fid(index, 1);
                x(i,1) = fid(index, 2);
            end
        end
        
        fid_o = ([y x]);

    end

end
