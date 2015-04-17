function generate_9_bar_graph(out_1, out_2, out_3, out_4, out_5, title_str)

    chehra_c     =  'cyan';  
    deva_c       =  'yellow';
    intraface_c  =  'green';
    rcpr_c       =  'magenta';
    our_c        =  'blue';
    
    bar(1, out_1(1), chehra_c);
    hold on;
    bar(2, out_1(2), deva_c);
    hold on;
    bar(3, out_1(3), intraface_c);
    hold on;
    bar(4, out_1(4), rcpr_c);
    hold on;
    bar(5, out_1(5), our_c);
    hold on;
    bar(6, out_2(5), our_c);
    hold on;
    bar(7, out_3(5), our_c);
    hold on;
    bar(8, out_4(5), our_c);
    hold on;
    bar(9, out_5(5), our_c);
    hold on;
    title(title_str);
end