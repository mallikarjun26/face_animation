function error_measure_deva_analysis(path, number_of_samples)

    %
    addpath('../../belhumeur_face_alignment/utils/');
    load('~/data/face_animation/belhumeur_data/intermediate_results/global_model_map.mat');
    posemap = 90:-15:-90;
    
    if(~exist([path '/deva_data/error_measure/error_workspace.mat']))
        disp('Errors not computed yet. Computing now ..');
        [err_measure, deva_bbs, global_model_map, global_fiducials] = find_error_measure(path, number_of_samples);
        save( [path '/deva_data/error_measure/error_workspace.mat'], 'err_measure', 'deva_bbs', 'global_model_map', 'global_fiducials');
    else
        disp('Errors already computed. Loading ..');
        load([path '/deva_data/error_measure/error_workspace.mat']); 
    end
    
    err_cases = find(err_measure(:)>2);
    number_of_outliers = size(err_cases,1);
    
    hist(err_measure,100);
    pause;
    close;
    
    for i=1:number_of_outliers
       
        err_index = err_cases(i,1);
        im = imread(global_model_map{err_index});
        showboxes(im, deva_bbs{err_index}, posemap);
        plot_fiducials(im, global_fiducials{err_index,1})
        
        pause;
        close;
    end
    
    
end