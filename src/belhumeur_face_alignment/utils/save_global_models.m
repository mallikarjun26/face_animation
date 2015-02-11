% Given input path for the .pts file for each image, returns the fiducial points.

function save_global_models(path)

    %
    train_path = [path '/lfpw/trainset'];
    
    %
    images_path         = dir([train_path '/*.png']);
    fiducials_path      = dir([train_path '/*.pts']);
    number_of_training_models = size(images_path,1);
    global_model_map    = cell(number_of_training_models,1);
    global_fiducials    = cell(number_of_training_models,1);
    
    %
    
    for i=1:number_of_training_models
        
        global_model_map{i,1} = [ train_path '/' images_path(i).name];
        points_path           = [ train_path '/' fiducials_path(i).name];
        global_fiducials{i,1} = get_fiducials(points_path);
        
    end
    
    %
    save([path '/intermediate_results/global_model_map.mat'], 'global_model_map');
    save([path '/intermediate_results/global_fiducials.mat'], 'global_fiducials');
    
end

function [fid_pts] = get_fiducials(input_path)

    %
    fid = fopen(input_path);
    
    %
    fid_pts = textscan(fid, '%u %u', 'HeaderLines', 3);
    fid_pts = [fid_pts{2} fid_pts{1}];

end
