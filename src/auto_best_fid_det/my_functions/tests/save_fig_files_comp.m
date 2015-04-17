function save_fig_files_comp(wo_met, w_met, output_folder)

    
    %%
    h1 = figure;
    generate_bar_graph(wo_met.failure_rate, w_met.failure_rate, 'Failure Rate');
    
    %%
    h2 = figure;
    generate_bar_graph(wo_met.mean_err, w_met.mean_err, 'Mean Error');
    
    %%
    h3 = figure;
    subplot(4,5,1);
    generate_bar_graph(wo_met.mean_err_parts(1, :), w_met.mean_err_parts(1, :),'Right eyebrow right corner'); 
    subplot(4,5,2);                                                            
    generate_bar_graph(wo_met.mean_err_parts(2, :), w_met.mean_err_parts(2, :),'Right eyebrow center'); 
    subplot(4,5,3);                                                            
    generate_bar_graph(wo_met.mean_err_parts(3, :), w_met.mean_err_parts(3, :),'Right eyebrow left corner'); 
    subplot(4,5,4);                                                            
    generate_bar_graph(wo_met.mean_err_parts(4, :), w_met.mean_err_parts(4, :),'Left eyebrow right corner'); 
    subplot(4,5,5);                                                            
    generate_bar_graph(wo_met.mean_err_parts(5, :), w_met.mean_err_parts(5, :),'Left eyebrow center'); 
    subplot(4,5,6);                                                            
    generate_bar_graph(wo_met.mean_err_parts(6, :), w_met.mean_err_parts(6, :),'Left eyebrow left corner'); 
    subplot(4,5,7);                                                            
    generate_bar_graph(wo_met.mean_err_parts(7, :), w_met.mean_err_parts(7, :),'Nose tip top'); 
    subplot(4,5,8);                                                            
    generate_bar_graph(wo_met.mean_err_parts(8, :), w_met.mean_err_parts(8, :),'Nose tip right'); 
    subplot(4,5,9);                                                            
    generate_bar_graph(wo_met.mean_err_parts(9, :), w_met.mean_err_parts(9, :),'Nose tip bottom'); 
    subplot(4,5,10);
    generate_bar_graph(wo_met.mean_err_parts(10, :), w_met.mean_err_parts(10, :),'Nose tip left'); 
    subplot(4,5,11);                                                             
    generate_bar_graph(wo_met.mean_err_parts(11, :), w_met.mean_err_parts(11, :),'Right eye right corner'); 
    subplot(4,5,12);                                                             
    generate_bar_graph(wo_met.mean_err_parts(12, :), w_met.mean_err_parts(12, :),'Right eye left corner'); 
    subplot(4,5,13);                                                             
    generate_bar_graph(wo_met.mean_err_parts(13, :), w_met.mean_err_parts(13, :),'Left eye right corner'); 
    subplot(4,5,14);                                                             
    generate_bar_graph(wo_met.mean_err_parts(14, :), w_met.mean_err_parts(14, :),'Left eye left corner'); 
    subplot(4,5,15);                                                             
    generate_bar_graph(wo_met.mean_err_parts(15, :), w_met.mean_err_parts(15, :),'Lip right extreme corner'); 
    subplot(4,5,16);                                                             
    generate_bar_graph(wo_met.mean_err_parts(16, :), w_met.mean_err_parts(16, :),'Upper lip top'); 
    subplot(4,5,17);                                                             
    generate_bar_graph(wo_met.mean_err_parts(17, :), w_met.mean_err_parts(17, :),'Lip left extreme corner'); 
    subplot(4,5,18);                                                             
    generate_bar_graph(wo_met.mean_err_parts(18, :), w_met.mean_err_parts(18, :),'Lower lip bottom'); 
    subplot(4,5,19);                                                             
    generate_bar_graph(wo_met.mean_err_parts(19, :), w_met.mean_err_parts(19, :),'Lower lip top'); 
    subplot(4,5,20);                                                             
    generate_bar_graph(wo_met.mean_err_parts(20, :), w_met.mean_err_parts(20, :),'Lower lip bottom'); 
 
    saveas(h1, [output_folder 'fail_rate.fig'], 'fig');
    saveas(h2, [output_folder 'mean_err.fig'], 'fig');
    saveas(h3, [output_folder 'mean_err_parts.fig'], 'fig');

end
