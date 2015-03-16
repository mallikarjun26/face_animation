function comp_models(path, list_of_faces, dataset, awesome_enable)

    close all;

    %
    if(dataset == 'jack') 
        load([path '/chehra_data/intermediate_results/chehra_fids.mat']);
        load([path '/deva_data/intermediate_results/deva_fids.mat']);
        load([path '/rcpr_data/intermediate_results/rcpr_fids.mat']);
        load([path '/intraface_data/intermediate_results/intraface_fids.mat']);
        load([path '/Faces5000/intermediate_results/facemap.mat']);
    else if(dataset == 'lfpw')
        load([path '/lfpw_data/chehra_fids.mat']);
        load([path '/lfpw_data/deva_fids.mat']);
        load([path '/lfpw_data/rcpr_fids.mat']);
        load([path '/lfpw_data/intraface_fids.mat']);
        load([path '/lfpw_data/facemap.mat']);
        if(awesome_enable)
            load([path '/lfpw_data/app_based_results/selected_models.mat'])
        else
            selected_models = zeros(size(list_of_faces,1),1); 
        end
    else
        load([path '/cofw_data/chehra_fids.mat']);
        load([path '/cofw_data/deva_fids.mat']);
        load([path '/cofw_data/rcpr_fids.mat']);
        load([path '/cofw_data/intraface_fids.mat']);
        load([path '/cofw_data/facemap.mat']);
        if(awesome_enable)
            load([path '/cofw_data/app_based_results/selected_models.mat'])
        else
            selected_models = zeros(size(list_of_faces,1),1); 
        end
    end

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
            if(selected_models(list_of_faces(i,1))==1)
                plot_chehra_fids(chehra_fids{list_of_faces(i,1)}, im, 0, 1, 'b.');
            else
                plot_chehra_fids(chehra_fids{list_of_faces(i,1)}, im, 0, 1, 'r.');
            end
        end
        title('Chehra fids');
        
        subplot(1,4,2);imshow(im);
        hold on;
        if(~isempty(deva_fids{list_of_faces(i,1)}))
            if(selected_models(list_of_faces(i,1))==2)
                plot_deva_fids(deva_fids{list_of_faces(i,1)}, im, 0, 1, 'b.');
            else
                plot_deva_fids(deva_fids{list_of_faces(i,1)}, im, 0, 1, 'r.');
            end
        end
        title('Deva fids');
        
        subplot(1,4,3);imshow(im);
        hold on;
        if(~isempty(intraface_fids{list_of_faces(i,1)}))
            if(selected_models(list_of_faces(i,1))==3)
                plot_intraface_fids(intraface_fids{list_of_faces(i,1)}, im, 0, 1, 'b.');
            else
                plot_intraface_fids(intraface_fids{list_of_faces(i,1)}, im, 0, 1, 'r.');
            end
        end
        title('Intraface fids');

        subplot(1,4,4);imshow(im);
        hold on;
        if(~isempty(rcpr_fids{list_of_faces(i,1)}))
            if(selected_models(list_of_faces(i,1))==4)
                plot_rcpr_fids(rcpr_fids{list_of_faces(i,1)}, im, 0, 1, 'b.');
            else
                plot_rcpr_fids(rcpr_fids{list_of_faces(i,1)}, im, 0, 1, 'r.');
            end
        end
        title('RCPR fids');
        
        %saveas(h, ['/home/mallikarjun/data/results/26_feb/452_dec_th_intraface/' num2str(list_of_faces(i,1)) '.jpg']);
        saveas(h, [path '/' dataset '_data/visual_results/' num2str(i) '.jpg']);
        
    end
        
end
