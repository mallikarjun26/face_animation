function generate_5_bar_graph(fail_rate, title_str)

    chehra_c     =  'cyan';  
    deva_c       =  'yellow';
    intraface_c  =  'green';
    rcpr_c       =  'magenta';
    our_c        =  'blue';
    
    bar(1, fail_rate(1), chehra_c);
    hold on;
    bar(2, fail_rate(2), deva_c);
    hold on;
    bar(3, fail_rate(3), intraface_c);
    hold on;
    bar(4, fail_rate(4), rcpr_c);
    hold on;
    bar(5, fail_rate(5), our_c);
    title(title_str);
end