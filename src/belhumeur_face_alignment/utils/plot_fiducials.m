% Given image and fiducial points in array, plots the data

function plot_fiducials(im, fid_pts)

    %fig_h = figure;
    %imshow(im);
    hold on;

    %plot(xy(:,1),xy(:,2),'r.','markersize',15);
    
    number_of_fiducials = size(fid_pts, 1);
    
    for i=1:number_of_fiducials
        plot(fid_pts(i,2),fid_pts(i,1),'r.','markersize',15);
        hold on;
    end
    
end
