
dataset = 'lfpw';

addpath '../util/';
load(['~/data/iccv/common_data/fids_mapping/chehra_deva_intraface_rcpr_common_fids.mat']);
load(['~/data/iccv/' dataset '_data/facemap.mat']);
load(['~/data/iccv/' dataset '_data/deva_fids.mat']);
load(['~/data/iccv/' dataset '_data/modi_deva_fids.mat']);

h=figure;
%for i=1:50
for i=1:size(b,1)
    
    face_num = 811 + b(i);
    %face_num = 1345 + i;
    
    clf;
    subplot(1,2,1);
    im = imread(facemap{face_num});
    fids = deva_fids{face_num};
    imshow(im);
    hold on;
    plot_deva_fids(fids,im,0,0,'.r');
    subplot(1,2,2);
    fids = modi_deva_fids{face_num};
    imshow(im);
    hold on;
    plot_deva_fids(fids,im,0,0,'.b');
    path = '/home/mallikarjun/data/iccv' ;
    pause;
    %saveas(h,['/home/mallikarjun/data/results/15_april/deva_improvements/' num2str(i) '.jpg']);
end