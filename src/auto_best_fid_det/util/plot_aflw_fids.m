function plot_intraface_fids(fids, im, show_image, show_fid_number, mark_color)

    %
    if(isempty(fids))
        disp('plot_intraface_fids:: fids are empty');
        return;
    end

    %
    number_of_fids = size(fids, 1);
    
    %
    if(show_image)
        figure;imshow(im);
        hold on;
    end
    
    %
    for i=1:number_of_fids
        plot(fids(i,2), fids(i,1), mark_color, 'MarkerSize', 12);
        
        x_t = double(fids(i,2)+2);
        y_t = double(fids(i,1)+2);
        if(show_fid_number)
            text(x_t, y_t, num2str(i), 'fontsize', 12);
        end
        hold on;
    end

end
