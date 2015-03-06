function comp_models(path, list_of_faces)

    clc; close all;

    %
    load([path '/chehra_data/intermediate_results/chehra_fids.mat']);
    load([path '/deva_data/intermediate_results/deva_fids.mat']);
    load([path '/rcpr_data/intermediate_results/rcpr_fids.mat']);
    load([path '/intraface_data/intermediate_results/intraface_fids.mat']);
    load([path '/Faces5000/intermediate_results/facemap.mat']);
    
    %
    number_of_faces = size(list_of_faces,1);
    
    %
    h = figure;
    for i=1:number_of_faces
        im = imread(facemap{1,list_of_faces(i,1)});
        clf;
        disp(num2str(list_of_faces(i,1)));
        
        subplot(1,4,1);imshow(im);
        hold on;
        if(~isempty(chehra_fids{list_of_faces(i,1)}))
            plot_chehra_fids(chehra_fids{list_of_faces(i,1)}, im, 0, 1);
        end
        title('Chehra fids');
        
        subplot(1,4,2);imshow(im);
        hold on;
        if(~isempty(deva_fids{list_of_faces(i,1)}))
            plot_deva_fids(deva_fids{list_of_faces(i,1)}, im, 0, 1);
        end
        title('Deva fids');
        
        subplot(1,4,3);imshow(im);
        hold on;
        if(~isempty(intraface_fids{list_of_faces(i,1)}))
            plot_intraface_fids(intraface_fids{list_of_faces(i,1)}, im, 0, 1);
        end
        title('Intraface fids');

        subplot(1,4,4);imshow(im);
        hold on;
        if(~isempty(rcpr_fids{list_of_faces(i,1)}))
            plot_rcpr_fids(rcpr_fids{list_of_faces(i,1)}, im, 0, 1);
        end
        title('RCPR fids');
        
        %saveas(h, ['/home/mallikarjun/data/results/26_feb/452_dec_th_intraface/' num2str(list_of_faces(i,1)) '.jpg']);
        %saveas(h, ['/home/mallikarjun/Desktop/dump/' num2str(list_of_faces(i,1)) '.jpg']);
        
        pause;
    end
        
end
