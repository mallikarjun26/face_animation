function [shape_diff, app_diff_avg, app_diff_min] = get_app_measure(path, input_image_num_list, dataset)

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
    elseif(dataset == 'lfpw')
        load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
        load([path '/lfpw_data/app_based_results/chehra_app_vector.mat']);
        load([path '/lfpw_data/app_based_results/deva_app_vector.mat']);
        load([path '/lfpw_data/app_based_results/intraface_app_vector.mat']);
        load([path '/lfpw_data/app_based_results/rcpr_app_vector.mat']);
    else
        load([path '/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
        load([path '/cofw_data/app_based_results/chehra_app_vector.mat']);
        load([path '/cofw_data/app_based_results/deva_app_vector.mat']);
        load([path '/cofw_data/app_based_results/intraface_app_vector.mat']);
        load([path '/cofw_data/app_based_results/rcpr_app_vector.mat']);
    end

    %
    sim_image_num_list   = get_sim_image_list(dataset);

    shape_diff = cell(size(input_image_num_list,1),1);
    app_diff_avg = cell(size(input_image_num_list,1),1  );
    app_diff_min = cell(size(input_image_num_list,1),1  );
    
    number_of_faces = size(input_image_num_list,1);
    for i=1:number_of_faces

        tic;
        disp([num2str(i) '/' num2str(size(input_image_num_list,1)) ' running']);

        input_image_num = input_image_num_list(i);
        
        chehra_face_app = chehra_app_vector{input_image_num};
        deva_face_app = deva_app_vector{input_image_num};
        intraface_face_app = intraface_app_vector{input_image_num};
        rcpr_face_app = rcpr_app_vector{input_image_num};

        app_chehra = 0;
        app_deva   = 0;
        app_intraface = 0;
        app_rcpr = 0;
        
        app_chehra_min = realmax;
        app_deva_min   = realmax;
        app_intraface_min = realmax;
        app_rcpr_min = realmax;
        
        for j=1:size(sim_image_num_list,1)
            %disp(['    ' num2str(j) '/' num2str(size(sim_image_num_list,1)) ' running']);

            sim_image_num   = sim_image_num_list{j}.face;
            sim_model       = sim_image_num_list{j}.id;
            sim_face_app    = get_sim_face_app(sim_image_num, sim_model, intraface_app_vector, deva_app_vector); 

            %
            [app_chehra_t, app_deva_t, app_intraface_t, app_rcpr_t] = get_appearance_similarity(chehra_face_app, deva_face_app, intraface_face_app, rcpr_face_app, sim_face_app);

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
        
        app_diff_avg{i} = app_diff_avg_t;
        app_diff_min{i} = app_diff_min_t;

        disp(['Time taken ' num2str(toc)]);
    end

    save([path '/' dataset '_data/app_based_results/app_based_results.mat'], 'app_diff_avg', 'app_diff_min');
    
end


function [app_chehra_t, app_deva_t, app_intraface_t, app_rcpr_t] = get_appearance_similarity(chehra_face_app, deva_face_app, intraface_face_app, rcpr_face_app, sim_face_app)
    
    number_of_parts = size(chehra_face_app,1);
    app_chehra_t = 0;
    app_deva_t = 0;
    app_intraface_t = 0;
    app_rcpr_t = 0;

    for i=1:number_of_parts
        t_s = double(sim_face_app{i});
        t_1 = double(chehra_face_app{i});
        t_2 = double(deva_face_app{i});
        t_3 = double(intraface_face_app{i});
        t_4 = double(rcpr_face_app{i});

        app_chehra_t     = app_chehra_t + pdist([t_s; t_1]);
        app_deva_t       = app_deva_t + pdist([t_s; t_2]);
        app_intraface_t  = app_intraface_t + pdist([t_s; t_3]);
        app_rcpr_t       = app_rcpr_t + pdist([t_s; t_4]);
    end

    app_chehra_t = app_chehra_t / number_of_parts;
    app_deva_t = app_deva_t / number_of_parts;
    app_intraface_t = app_intraface_t / number_of_parts;
    app_rcpr_t = app_rcpr_t / number_of_parts;

end

function sim_face_app = get_sim_face_app(sim_image_num, sim_model, intraface_app_vector, deva_app_vector)
    
    if(sim_model==3)
        sim_face_app = intraface_app_vector{sim_image_num};
    else
        sim_face_app = deva_app_vector{sim_image_num};
    end

end

function sim_image_num_list= get_sim_image_list(dataset)

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
        sim_image_num_list = cell(11,1);
        
        sim_image_num_list{1}.face = 20 ;
        sim_image_num_list{1}.id =   3 ;
        sim_image_num_list{2}.face = 140 ;
        sim_image_num_list{2}.id =   3 ;
        sim_image_num_list{3}.face = 44 ;
        sim_image_num_list{3}.id =   3 ;

        sim_image_num_list{4}.face = 87 ;
        sim_image_num_list{4}.id =   3 ;
        sim_image_num_list{5}.face = 157 ;
        sim_image_num_list{5}.id =   3 ;
        sim_image_num_list{6}.face = 3 ;
        sim_image_num_list{6}.id =   3 ;
        sim_image_num_list{7}.face = 1 ;
        sim_image_num_list{7}.id =   3 ;
        sim_image_num_list{8}.face = 59 ;
        sim_image_num_list{8}.id =   3 ;
        
        sim_image_num_list{9}.face = 90 ;
        sim_image_num_list{9}.id =   3 ;
        sim_image_num_list{10}.face = 76 ;
        sim_image_num_list{10}.id =   3 ;
        sim_image_num_list{11}.face = 113 ;
        sim_image_num_list{11}.id =   3 ;
    else
        
        sim_image_num_list = cell(11,1);
        
        sim_image_num_list{1}.face = 7 ;
        sim_image_num_list{1}.id =   3 ;
        sim_image_num_list{2}.face = 56 ;
        sim_image_num_list{2}.id =   3 ;
        sim_image_num_list{3}.face = 5 ;
        sim_image_num_list{3}.id =   3 ;

        sim_image_num_list{4}.face = 58 ;
        sim_image_num_list{4}.id =   3 ;
        sim_image_num_list{5}.face = 34 ;
        sim_image_num_list{5}.id =   3 ;
        sim_image_num_list{6}.face = 13 ;
        sim_image_num_list{6}.id =   3 ;
        sim_image_num_list{7}.face = 47 ;
        sim_image_num_list{7}.id =   3 ;
        sim_image_num_list{8}.face = 48 ;
        sim_image_num_list{8}.id =   3 ;
        
        sim_image_num_list{9}.face = 14 ;
        sim_image_num_list{9}.id =   3 ;
        sim_image_num_list{10}.face = 18 ;
        sim_image_num_list{10}.id =   3 ;
        sim_image_num_list{11}.face = 6 ;
        sim_image_num_list{11}.id =   3 ;

    end

end
