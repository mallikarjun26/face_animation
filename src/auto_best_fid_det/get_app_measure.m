function [shape_diff, app_diff_avg, app_diff_min] = get_app_measure(path, input_image_num_list, dataset, auto_train_select, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn)

    %
    clc;
    run('/home/mallikarjun/src/vlfeat/vlfeat-0.9.19/toolbox/vl_setup')
    
    %
    if(dataset == 'jack')
        load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
        load([path '/jack_data/app_based_results/chehra_app_vector.mat']);
        load([path '/jack_data/app_based_results/deva_app_vector.mat']);
        load([path '/jack_data/app_based_results/intraface_app_vector.mat']);
        load([path '/jack_data/app_based_results/rcpr_app_vector.mat']);
    else
        load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
        load([path '/' dataset '_data/app_based_results/chehra_app_vector.mat']);
        load([path '/' dataset '_data/app_based_results/deva_app_vector.mat']);
        load([path '/' dataset '_data/app_based_results/intraface_app_vector.mat']);
        load([path '/' dataset '_data/app_based_results/rcpr_app_vector.mat']);
        load([path '/' dataset '_data/app_based_results/ground_truth_app_vector.mat']);
        load([path '/' dataset '_data/app_based_results/M.mat']);
    end

    %
    sim_image_num_list   = get_sim_image_list(dataset, path, auto_train_select, kmeans_pca_mode, shape_app_mode);

    shape_diff = cell(size(input_image_num_list,1),1);
    app_diff_avg = cell(size(input_image_num_list,1),1  );
    app_diff_min = cell(size(input_image_num_list,1),1  );
    k_near_exemplars = containers.Map('KeyType', 'int32', 'ValueType', 'any'); 
    
    number_of_faces = size(input_image_num_list,1);
    part_score = containers.Map('KeyType', 'int32', 'ValueType', 'any');

    for i=1:number_of_faces

        tic;
        if(mod(i,100)==0)
            disp([num2str(i) '/' num2str(size(input_image_num_list,1)) ' running']);
        end

        input_image_num = input_image_num_list(i);
        
        chehra_face_app = chehra_app_vector{input_image_num};
        deva_face_app = deva_app_vector{input_image_num};
        intraface_face_app = intraface_app_vector{input_image_num};
        rcpr_face_app = rcpr_app_vector{input_image_num};

        app_chehra_t = realmax * ones(size(sim_image_num_list,1),1);
        app_deva_t = realmax * ones(size(sim_image_num_list,1),1);
        app_intraface_t = realmax * ones(size(sim_image_num_list,1),1);
        app_rcpr_t = realmax * ones(size(sim_image_num_list,1),1);

        part_score_sample = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        for j=1:size(sim_image_num_list,1)
            %disp(['    ' num2str(j) '/' num2str(size(sim_image_num_list,1)) ' running']);

            sim_image_num   = sim_image_num_list(j);
            sim_face_app    = get_sim_face_app(sim_image_num, ground_truth_app_vector); 

            %
            [app_chehra_t(j), app_deva_t(j), app_intraface_t(j), app_rcpr_t(j), part_score_sample(sim_image_num)] = get_appearance_similarity(chehra_face_app, deva_face_app, intraface_face_app, rcpr_face_app, sim_face_app, L, metric_learning_enabled, hog_sift_mode);

        end
        
        part_score(input_image_num) = part_score_sample;

        nearest_exem = cell(4,1);

        [app_chehra_t, nearest_exem{1}] = sort(app_chehra_t);
        [app_deva_t, nearest_exem{2}]= sort(app_deva_t);
        [app_intraface_t, nearest_exem{3}] = sort(app_intraface_t);
        [app_rcpr_t, nearest_exem{4}] = sort(app_rcpr_t);

        nearest_exem{1} = sim_image_num_list(nearest_exem{1});
        nearest_exem{2} = sim_image_num_list(nearest_exem{2});
        nearest_exem{3} = sim_image_num_list(nearest_exem{3});
        nearest_exem{4} = sim_image_num_list(nearest_exem{4});

        k_near_exemplars(input_image_num) = nearest_exem;

        app_diff_avg_t.app_chehra = sum(app_chehra_t(:)) / size(sim_image_num_list, 1);
        app_diff_avg_t.app_deva = sum(app_deva_t(:)) / size(sim_image_num_list, 1);
        app_diff_avg_t.app_intraface = sum(app_intraface_t(:)) / size(sim_image_num_list, 1);
        app_diff_avg_t.app_rcpr = sum(app_rcpr_t(:)) / size(sim_image_num_list, 1);

        app_diff_min_t.app_chehra = app_chehra_t(1:k_in_knn) / k_in_knn; 
        app_diff_min_t.app_deva = app_deva_t(1:k_in_knn) / k_in_knn; 
        app_diff_min_t.app_intraface = app_intraface_t(1:k_in_knn) / k_in_knn; 
        app_diff_min_t.app_rcpr = app_rcpr_t(1:k_in_knn) / k_in_knn; 
        
        app_diff_avg{i} = app_diff_avg_t;
        app_diff_min{i} = app_diff_min_t;

        % disp(['Time taken ' num2str(toc)]);
    end

    save([path '/' dataset '_data/k_near_exemplars.mat'], 'k_near_exemplars');
    save([path '/' dataset '_data/part_score.mat'], 'part_score');

    if(auto_train_select == 1)
        save([path '/' dataset '_data/app_based_results/app_based_results_auto.mat'], 'app_diff_avg', 'app_diff_min');
    else
        save([path '/' dataset '_data/app_based_results/app_based_results_manual.mat'], 'app_diff_avg', 'app_diff_min');
    end
    
end


function [app_chehra_t, app_deva_t, app_intraface_t, app_rcpr_t, part_score_sample] = get_appearance_similarity(chehra_face_app, deva_face_app, intraface_face_app, rcpr_face_app, sim_face_app, L, metric_learning_enabled, hog_sift_mode)
    
    number_of_parts = size(chehra_face_app,1);
    app_chehra_t = 0;
    app_deva_t = 0;
    app_intraface_t = 0;
    app_rcpr_t = 0;
    number_of_deva_parts = 0;

    actual_number_of_parts = 0;
    part_score_sample = NaN * ones(4, number_of_parts);

    for i=1:number_of_parts
        t_s = double(sim_face_app{i});
        t_1 = double(chehra_face_app{i});
        t_2 = double(deva_face_app{i});
        t_3 = double(intraface_face_app{i});
        t_4 = double(rcpr_face_app{i});
    
        switch hog_sift_mode
            case 1
                   t_s = t_s(1:279);
                   t_1 = t_1(1:279);
                   t_2 = t_2(1:279);
                   t_3 = t_3(1:279);
                   t_4 = t_4(1:279);
            case 2
                   t_s = t_s(280:535);
                   t_1 = t_1(280:535);
                   t_2 = t_2(280:535);
                   t_3 = t_3(280:535);
                   t_4 = t_4(280:535);
        end 
            

        if(isnan(t_s(1)))
            continue;
        end

        if((metric_learning_enabled == 1) && (hog_sift_mode == 3))
            t_s = t_s * L{i}';
            t_1 = t_1 * L{i}';
            t_2 = t_2 * L{i}';
            t_3 = t_3 * L{i}';
            t_4 = t_4 * L{i}';
        end

        actual_number_of_parts = actual_number_of_parts + 1;

        part_score_sample(1, i) = pdist([t_s; t_1]);
        part_score_sample(2, i) = pdist([t_s; t_2]);
        part_score_sample(3, i) = pdist([t_s; t_3]);
        part_score_sample(4, i) = pdist([t_s; t_4]);

        app_chehra_t     = app_chehra_t + part_score_sample(1,i); 
        if(~isnan(t_2(1,1)))
            number_of_deva_parts = number_of_deva_parts + 1;
            app_deva_t       = app_deva_t + part_score_sample(2,i); 
        end
        app_intraface_t  = app_intraface_t + part_score_sample(3,i); 
        app_rcpr_t       = app_rcpr_t + part_score_sample(4,i); 
    end

    app_chehra_t = app_chehra_t / actual_number_of_parts;
    app_deva_t = app_deva_t / number_of_deva_parts;
    app_intraface_t = app_intraface_t / actual_number_of_parts;
    app_rcpr_t = app_rcpr_t / actual_number_of_parts;

end

function sim_face_app = get_sim_face_app(sim_image_num, ground_truth_app_vector)
    
    sim_face_app = ground_truth_app_vector{sim_image_num};

end

function sim_image_num_list= get_sim_image_list(dataset, path, auto_train_select, kmeans_pca_mode, shape_app_mode)

    if(dataset == 'jack')

        sim_image_num_list = cell(11,1);
        
        sim_image_num_list{1}.face = 261 ;
        sim_image_num_list{1}.id =   3 ;
        sim_image_num_list{2}.face = 255 ;
        sim_image_num_list{2}.id =   3 ;
        sim_image_num_list{3}.face = 264 ;
        sim_image_num_list{3}.id =   3 ;

        sim_image_num_list{4}.face = 2699 ;
        sim_image_num_list{4}.id =   5 ;
        sim_image_num_list{5}.face = 110 ;
        sim_image_num_list{5}.id =   3 ;
        sim_image_num_list{6}.face = 170 ;
        sim_image_num_list{6}.id =   3 ;
        sim_image_num_list{7}.face = 157 ;
        sim_image_num_list{7}.id =   3 ;
        sim_image_num_list{8}.face = 1043 ;
        sim_image_num_list{8}.id =   6 ;

        sim_image_num_list{9}.face = 162 ;
        sim_image_num_list{9}.id =   3 ;
        sim_image_num_list{10}.face = 385 ;
        sim_image_num_list{10}.id =   3 ;
        sim_image_num_list{11}.face = 217 ;
        sim_image_num_list{11}.id =   3 ;

    elseif(dataset == 'lfpw')

        if(auto_train_select == 1)
            if(shape_app_mode == 1)
                shape_app_l = 'shape_en';
            else
                shape_app_l = 'app_en';
            end

            if(kmeans_pca_mode == 1)
                load([path '/lfpw_data/sim_image_list_kmeans_' shape_app_l '.mat']);
            else
                load([path '/lfpw_data/sim_image_list_pca_' shape_app_l '.mat']);
            end
            sim_image_num_list = sim_list ;
        else
            sim_image_num_list = [ 20; 140; 44; 87; 157; 3; 1; 59; 90; 76; 113 ]; 
        end

    elseif(dataset == 'cofw')
        if(shape_app_mode == 1)
            shape_app_l = 'shape_en';
        else
            shape_app_l = 'app_en';
        end
        
        if(auto_train_select == 1)
            if(kmeans_pca_mode == 1)
                load([path '/cofw_data/sim_image_list_kmeans_' shape_app_l '.mat']);
            else
                load([path '/cofw_data/sim_image_list_pca_' shape_app_l '.mat']);
            end

            sim_image_num_list = sim_list ;
        else
            sim_image_num_list = [ 7; 56; 5; 58; 34; 13; 47; 48; 14; 18; 6 ]; 
        end

    elseif(dataset == 'aflw')
        if(shape_app_mode == 1)
            shape_app_l = 'shape_en';
        else
            shape_app_l = 'app_en';
        end
        
        if(auto_train_select == 1)
            if(kmeans_pca_mode == 1)
                load([path '/aflw_data/sim_image_list_kmeans_' shape_app_l '.mat']);
            else
                load([path '/aflw_data/sim_image_list_pca_' shape_app_l '.mat']);
            end
            sim_image_num_list = sim_list ;
        else
            sim_image_num_list = [ 7; 56; 5; 58; 34; 13; 47; 48; 14; 18; 6 ]; 
        end

    end

end
