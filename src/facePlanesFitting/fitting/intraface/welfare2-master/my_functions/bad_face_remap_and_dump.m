function bad_face_remap_and_dump(path, b_l)

    %
    load([path '/Faces5000/intermediate_results/facemap.mat']);

    %
    number_of_faces = size(b_l,1);

    
    %
    for i=1:number_of_faces
       
        fid_p = fopen(['/home/mallikarjun/projects/face_animation/src/facePlanesFitting/fitting/intraface/welfare2-master/my_functions/failed_intraface_results/' num2str(i) '.txt']);
        a = textscan(fid_p, '%f %f', 'HeaderLines', 2);
        
        fid = ([a{1,1} a{1,2}]);
        
        f_n = [path '/intraface_data/fid_files/' num2str(b_l(i)) '.txt'];
        dlmwrite(f_n, fid, ' ');
    end
    
end