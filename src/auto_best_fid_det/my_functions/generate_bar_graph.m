function generate_bar_graph(wo_data, w_data, x_str)

    %
    chehra_c     =  'cyan';  
    deva_c       =  'yellow';
    intraface_c  =  'green';
    rcpr_c       =  'magenta';
    wo_our_c        =  'blue';
    w_our_c        =  'black';

    bar(1, wo_data(1), chehra_c);
    hold on;
    bar(2, wo_data(2), deva_c);
    hold on;
    bar(3, wo_data(3), intraface_c);
    hold on;
    bar(4, wo_data(4), rcpr_c);
    hold on;
    bar(5, wo_data(5), wo_our_c);
    hold on;
    bar(6, w_data(5), w_our_c);
    title(x_str);

end
