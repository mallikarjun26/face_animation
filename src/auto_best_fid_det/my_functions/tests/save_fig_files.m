function save_fig_files(fail_rate, mean_err, mean_err_parts, output_folder)
    
    %%
    h1 = figure;
    generate_5_bar_graph(fail_rate, 'Failure Rate');
    
    %%
    h2 = figure;
    generate_5_bar_graph(mean_err, 'Mean Error');
    
    %%
    h3 = figure;
    subplot(4,5,1);
    generate_5_bar_graph(mean_err_parts(1, :), 'Right eyebrow right corner'); 
    subplot(4,5,2);
    generate_5_bar_graph(mean_err_parts(2, :), 'Right eyebrow center'); 
    subplot(4,5,3);
    generate_5_bar_graph(mean_err_parts(3, :), 'Right eyebrow left corner'); 
    subplot(4,5,4);
    generate_5_bar_graph(mean_err_parts(4, :), 'Left eyebrow right corner'); 
    subplot(4,5,5);
    generate_5_bar_graph(mean_err_parts(5, :), 'Left eyebrow center'); 
    subplot(4,5,6);
    generate_5_bar_graph(mean_err_parts(6, :), 'Left eyebrow left corner'); 
    subplot(4,5,7);
    generate_5_bar_graph(mean_err_parts(7, :), 'Nose tip top'); 
    subplot(4,5,8);
    generate_5_bar_graph(mean_err_parts(8, :), 'Nose tip right'); 
    subplot(4,5,9);
    generate_5_bar_graph(mean_err_parts(9, :), 'Nose tip bottom'); 
    subplot(4,5,10);
    generate_5_bar_graph(mean_err_parts(10, :), 'Nose tip left'); 
    subplot(4,5,11);
    generate_5_bar_graph(mean_err_parts(11, :), 'Right eye right corner'); 
    subplot(4,5,12);
    generate_5_bar_graph(mean_err_parts(12, :), 'Right eye left corner'); 
    subplot(4,5,13);
    generate_5_bar_graph(mean_err_parts(13, :), 'Left eye right corner'); 
    subplot(4,5,14);
    generate_5_bar_graph(mean_err_parts(14, :), 'Left eye left corner'); 
    subplot(4,5,15);
    generate_5_bar_graph(mean_err_parts(15, :), 'Lip right extreme corner'); 
    subplot(4,5,16);
    generate_5_bar_graph(mean_err_parts(16, :), 'Upper lip top'); 
    subplot(4,5,17);
    generate_5_bar_graph(mean_err_parts(17, :), 'Lip left extreme corner'); 
    subplot(4,5,18);
    generate_5_bar_graph(mean_err_parts(18, :), 'Lower lip bottom'); 
    subplot(4,5,19);
    generate_5_bar_graph(mean_err_parts(19, :), 'Lower lip top'); 
    subplot(4,5,20);
    generate_5_bar_graph(mean_err_parts(20, :), 'Lower lip bottom'); 
 
    saveas(h1, [output_folder 'fail_rate.fig'], 'fig');
    saveas(h2, [output_folder 'mean_err.fig'], 'fig');
    saveas(h3, [output_folder 'mean_err_parts.fig'], 'fig');
    
end
