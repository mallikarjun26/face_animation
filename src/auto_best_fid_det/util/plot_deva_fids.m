function plot_deva_fids(fids, im, show_image, show_fid_number)

    %
    number_of_fids = size(fids.xy, 1);
    
    %
    if(show_image)
        figure;imshow(im);
        hold on;
    end
    
    %
    for i=1:number_of_fids
        
        x = double(uint32((fids.xy(i,1) + fids.xy(i,3)) / 2 ));
        y = double(uint32((fids.xy(i,2) + fids.xy(i,4)) / 2 ));
        
        plot(x, y,'b.', 'MarkerSize', 12);
        if(show_fid_number)
            text(x, y, num2str(i), 'fontsize', 12);
        end
        hold on;
    end

end