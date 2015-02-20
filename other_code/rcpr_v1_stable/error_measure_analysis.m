function [p,pRT, err_measure, global_fiducials, regModel] = error_measure_analysis(path, number_of_samples)

    load('~/data/face_animation/belhumeur_data/intermediate_results/global_model_map.mat');

    if(~exist([path '/rcpr_data/error_measure/error_workspace.mat']))
        disp('Errors not computed yet. Computing now ..');
        [p,pRT, err_measure, global_fiducials, regModel] = find_rcpr_error_measure(path, number_of_samples);
        save( [path '/rcpr_data/error_measure/error_workspace.mat'], 'p','pRT', 'err_measure', 'global_fiducials', 'regModel');
    else
        disp('Errors already computed. Loading ..');
        load([path '/rcpr_data/error_measure/error_workspace.mat']); 
    end
    
    err_cases = find(err_measure(:)>20);
    number_of_outliers = size(err_cases,1);
    
    hist(err_measure,100);
    pause;
    close;
    
    for i=1:number_of_outliers
       
        err_index = err_cases(i,1);
        im = imread(global_model_map{err_index});
        h =shapeGt('draw',regModel.model,im,p(err_index,:),{'lw',20});
        plot_fiducials(im, global_fiducials{err_index,1})
        
        pause;
        close;
    end
    
    
end