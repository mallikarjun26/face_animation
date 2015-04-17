addpath '../';
addpath '../../';
path = '/home/mallikarjun/data/iccv';
dataset = 'aflw';

%% Basic algorithm
metric_learning_enabled = 1;
hog_sift_mode = 2;
kmeans_pca_mode = 1;
shape_app_mode = 1;
k_in_knn = 1;
num_of_exemplars = 30;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);

output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
save_fig_files(fail_rate, mean_err, mean_err_parts, '~/data/results/iccv/aflw/basic_algorithm/');

%% Without metric learning vs metric learning enabled
metric_learning_enabled = 1;
hog_sift_mode = 2;
kmeans_pca_mode = 1;
shape_app_mode = 1;
k_in_knn = 1;
num_of_exemplars = 20;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);

wo_met.failure_rate     = fail_rate;
wo_met.mean_err         = mean_err;
wo_met.mean_err_parts   = mean_err_parts;

output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
w_met.failure_rate     = fail_rate;
w_met.mean_err         = mean_err;
w_met.mean_err_parts   = mean_err_parts;

save_fig_files_comp(wo_met, w_met, '~/data/results/iccv/aflw/wo_metric_vs_w_metric/');

%% HoG vs SIFT 
metric_learning_enabled = 0;
hog_sift_mode = 1;
kmeans_pca_mode = 1;
shape_app_mode = 1;
k_in_knn = 1;
num_of_exemplars = 20;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);

output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
w_hog.failure_rate     = fail_rate;
w_hog.mean_err         = mean_err;
w_hog.mean_err_parts   = mean_err_parts;

hog_sift_mode = 2;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);

output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
w_sift.failure_rate     = fail_rate;
w_sift.mean_err         = mean_err;
w_sift.mean_err_parts   = mean_err_parts;

save_fig_files_comp(w_hog, w_sift, '~/data/results/iccv/aflw/hog_vs_sift/');

%% kMeans Shape vs PCA Shape
metric_learning_enabled = 0;
hog_sift_mode = 2;
kmeans_pca_mode = 1;
shape_app_mode = 1;
k_in_knn = 1;
num_of_exemplars = 20;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
w_shape_kmeans.failure_rate     = fail_rate;
w_shape_kmeans.mean_err         = mean_err;
w_shape_kmeans.mean_err_parts   = mean_err_parts;

kmeans_pca_mode = 2;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
w_shape_pca.failure_rate     = fail_rate;
w_shape_pca.mean_err         = mean_err;
w_shape_pca.mean_err_parts   = mean_err_parts;

save_fig_files_comp(w_shape_kmeans, w_shape_pca, '~/data/results/iccv/aflw/shape_kmeans_vs_shape_pca/');

%% kMeans Appearance vs PCA Appearance
metric_learning_enabled = 0;
hog_sift_mode = 2;
kmeans_pca_mode = 1;
shape_app_mode = 2;
k_in_knn = 1;
num_of_exemplars = 20;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
w_app_kmeans.failure_rate     = fail_rate;
w_app_kmeans.mean_err         = mean_err;
w_app_kmeans.mean_err_parts   = mean_err_parts;

kmeans_pca_mode = 2;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
w_app_pca.failure_rate     = fail_rate;
w_app_pca.mean_err         = mean_err;
w_app_pca.mean_err_parts   = mean_err_parts;

save_fig_files_comp(w_app_kmeans, w_app_pca, '~/data/results/iccv/aflw/app_kmeans_vs_app_pca/');

%% kMeans Shape vs kMeans Appearance
metric_learning_enabled = 0;
hog_sift_mode = 2;
kmeans_pca_mode = 1;
shape_app_mode = 1;
k_in_knn = 1;
num_of_exemplars = 20;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
w_kmeans_shape.failure_rate     = fail_rate;
w_kmeans_shape.mean_err         = mean_err;
w_kmeans_shape.mean_err_parts   = mean_err_parts;

shape_app_mode = 2;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
w_kmeans_app.failure_rate     = fail_rate;
w_kmeans_app.mean_err         = mean_err;
w_kmeans_app.mean_err_parts   = mean_err_parts;

save_fig_files_comp(w_kmeans_shape, w_kmeans_app, '~/data/results/iccv/aflw/kmeans_shape_vs_kmeans_app/');

%% Varying number of exemplars
metric_learning_enabled = 0;
hog_sift_mode = 2;
kmeans_pca_mode = 1;
shape_app_mode = 1;
k_in_knn = 1;
num_of_exemplars = 10;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
exem_10.fail_rate = fail_rate;
exem_10.mean_err = mean_err;
exem_10.mean_err_parts = mean_err_parts;

num_of_exemplars = 15;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
exem_15.fail_rate = fail_rate;
exem_15.mean_err = mean_err;
exem_15.mean_err_parts = mean_err_parts;

num_of_exemplars = 20;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
exem_20.fail_rate = fail_rate;
exem_20.mean_err = mean_err;
exem_20.mean_err_parts = mean_err_parts;

num_of_exemplars = 25;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
exem_25.fail_rate = fail_rate;
exem_25.mean_err = mean_err;
exem_25.mean_err_parts = mean_err_parts;

num_of_exemplars = 30;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
exem_30.fail_rate = fail_rate;
exem_30.mean_err = mean_err;
exem_30.mean_err_parts = mean_err_parts;

save_fig_files_9_bars(exem_10, exem_15, exem_20, exem_25, exem_30, '~/data/results/iccv/aflw/num_of_exemplars/');

%% k in kNN
metric_learning_enabled = 0;
hog_sift_mode = 2;
kmeans_pca_mode = 1;
shape_app_mode = 1;
k_in_knn = 1;
num_of_exemplars = 30;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);

output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
kNN_1.fail_rate     = fail_rate;
kNN_1.mean_err         = mean_err;
kNN_1.mean_err_parts   = mean_err_parts;

k_in_knn = 2;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);

output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
kNN_2.fail_rate     = fail_rate;
kNN_2.mean_err         = mean_err;
kNN_2.mean_err_parts   = mean_err_parts;

k_in_knn = 3;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);

output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
kNN_3.fail_rate     = fail_rate;
kNN_3.mean_err         = mean_err;
kNN_3.mean_err_parts   = mean_err_parts;

k_in_knn = 4;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);

output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
kNN_4.fail_rate     = fail_rate;
kNN_4.mean_err         = mean_err;
kNN_4.mean_err_parts   = mean_err_parts;

k_in_knn = 5;
generate_graphs(path, dataset, metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);

output_file_name = get_output_file_name(metric_learning_enabled, hog_sift_mode, kmeans_pca_mode, shape_app_mode, k_in_knn, num_of_exemplars);
load(['~/data/iccv/' dataset '_data/results/' output_file_name]);
kNN_5.fail_rate     = fail_rate;
kNN_5.mean_err         = mean_err;
kNN_5.mean_err_parts   = mean_err_parts;
close all;
save_fig_files_9_bars(kNN_1, kNN_2, kNN_3, kNN_4, kNN_5, '~/data/results/iccv/aflw/k_in_knn/');


