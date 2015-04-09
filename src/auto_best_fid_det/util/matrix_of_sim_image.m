function matrix_of_sim_image(path, dataset, sim_list)

    %
    addpath(genpath('/home/mallikarjun/src/subtightplot'));
    load([path '/' dataset '_data/facemap.mat']);
    subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);

    %%
    figure
    for i=1:20
        subplot(4,5,i)
        im = imread(facemap{sim_list(i)});
        im = imresize(im, [200 200]);
        imshow(im);
    end

% subplot(2,2,2)
% im = imread(facemap{sim_list(2)});
% imshow(im);
% 
% subplot(2,2,3)
% im = imread(facemap{sim_list(3)});
% imshow(im);
% 
% subplot(2,2,4)
% im = imread(facemap{sim_list(4)});
% imshow(im);
%%
    
    %
    h = figure;
    
    for i=1:20
        im = imread(facemap{sim_list(i)});
        subplot(4, 5, i)
        text(.5,.5,{'subplot(2,2,4)';'or subplot 224'},...
    'FontSize',14,'HorizontalAlignment','center')
        imshow(im);
    end

    %
    pause;
end