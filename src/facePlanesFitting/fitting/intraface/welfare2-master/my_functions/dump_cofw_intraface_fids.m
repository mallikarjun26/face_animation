function dump_cofw_intraface_fids(path)

    %
    load([path '/cofw_data/facemap.mat']);
    
    %
    number_of_faces = size(facemap,2);
    intraface_fids = cell(number_of_faces,1);
    
    %
    for i=1:number_of_faces
       
        fid_file = [path '/cofw_data/intraface_fids/' num2str(i) '.txt'];
        fid = fopen(fid_file);
        file_content = textscan(fid, '%f %f');
        fclose(fid);
        intraface_fids{i} = uint16([file_content{1,2} file_content{1,1}]);
        
    end
    
    save([path '/cofw_data/intraface_fids.mat'], 'intraface_fids');
    
end
