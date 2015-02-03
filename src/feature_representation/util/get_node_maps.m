// Provides the node number to face file name mapping 

function [mapping] = get_node_maps(output_path)

    map_file_name = [output_path '/intermediate_results/face_map.mat'];
    faces_folder_name = [output_path '/faces/'];
    
    list_of_files_path = [output_path '/ListOfFaces.txt'];
    list_of_files_fileID = fopen(list_of_files_path);
    list_of_files_contents = textscan(list_of_files_fileID, '%s %u');    
    file_name_cell = list_of_files_contents{1,1};
    number_of_faces = size(file_name_cell, 1);
    
    for i=1:number_of_faces
        mapping{i} = [faces_folder_name file_name_cell{i}];
    end
    
    save(map_file_name, 'mapping');
    
end
