function save_fig_files_9_bars(out_1, out_2, out_3, out_4, out_5, output_folder)
    
    %%
    h1 = figure;
    generate_9_bar_graph(out_1.fail_rate, out_2.fail_rate, out_3.fail_rate, out_4.fail_rate, out_5.fail_rate, 'Failure Rate');
    
    %%
    h2 = figure;
    generate_9_bar_graph(out_1.mean_err, out_2.mean_err, out_3.mean_err, out_4.mean_err, out_5.mean_err, 'Mean Error');
    
    %%
    part_names = cell(20,1);
    part_names{1} = 'Right eyebrow right corner'; 
    part_names{2} = 'Right eyebrow center'; 
    part_names{3} = 'Right eyebrow left corner'; 
    part_names{4} = 'Left eyebrow right corner'; 
    part_names{5} = 'Left eyebrow center'; 
    part_names{6} = 'Left eyebrow left corner'; 
    part_names{7} = 'Nose tip top'; 
    part_names{8} = 'Nose tip right'; 
    part_names{9} = 'Nose tip bottom'; 
    part_names{10} = 'Nose tip left'; 
    part_names{11} = 'Right eye right corner'; 
    part_names{12} = 'Right eye left corner'; 
    part_names{13} = 'Left eye right corner'; 
    part_names{14} = 'Left eye left corner'; 
    part_names{15} = 'Lip right extreme corner'; 
    part_names{16} = 'Upper lip top'; 
    part_names{17} = 'Lip left extreme corner'; 
    part_names{18} = 'Lower lip bottom'; 
    part_names{19} = 'Lower lip top'; 
    part_names{20} = 'Lower lip bottom'; 

    h3 = figure;
    for i=1:20
        subplot(4,5,i);
        generate_9_bar_graph(out_1.mean_err_parts(i, :), out_2.mean_err_parts(i, :), out_3.mean_err_parts(i, :), out_4.mean_err_parts(i, :), out_5.mean_err_parts(i, :), part_names{i}); 
    end
 
    saveas(h1, [output_folder 'fail_rate.fig'], 'fig');
    saveas(h2, [output_folder 'mean_err.fig'], 'fig');
    saveas(h3, [output_folder 'mean_err_parts.fig'], 'fig');

end
