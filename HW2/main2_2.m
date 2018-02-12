% Author: Xinshuo
% Email: xinshuow@andrew.cmu.edu

clc;
clear('all');
close all;
startup();

rng(1);
debug_mode = true;
vis_mode = true;
data_path = './data';
save_dir = './results/q2_2';
mkdir_if_missing(data_path);
mkdir_if_missing(save_dir);
num_vp = 3;
num_iter = 50000; 		% for RANSAC
error_threshold = 30;	% threshold for counting the example within the inlier set



image_name = '02';
image_file = sprintf('./images/extracredits/%s.jpg', image_name);
assert(exist(image_file, 'file') ~= 0, 'the image does not exist');
img = imread(image_file);
[~, filename, ~] = fileparts(image_file);
save_intermediate_vp_data = fullfile(data_path, sprintf('%s_vp.mat', filename));

if exist(save_intermediate_vp_data, 'file')
	fprintf('load the data for vanishing point from %s\n', save_intermediate_vp_data)
	load(save_intermediate_vp_data);
else
	fprintf('compute and save intermediate data for vanishing point to %s\n', save_intermediate_vp_data);
	[VPs linemem p lines] = getVPHedauRaw(img);
	save(save_intermediate_vp_data, 'VPs', 'linemem', 'p', 'lines');
end

corresponding_lines = cell(3, 1);
for vp_index = 1:3
	line_index = find(linemem == vp_index);
	line_tmp = lines(line_index, 1:4);
	corresponding_lines{vp_index} = line_tmp;
end

VPs = reshape(VPs, 2, 3);

if vis_mode
	color_set = ['r', 'g', 'b', 'k', 'y', 'm', 'c', 'w'];
	save_path = '';
	label = false;
	label_str = '';
	vis_radius = 10;
	vis_resize_factor = 1;
	closefig = false;
	mark_index = 1;
	for cluster_index = 1:num_vp
		color_index = cluster_index;
		img_with_pts = visualize_image_with_pts(img, VPs(:, cluster_index), vis_mode, debug_mode, save_path, label, label_str, vis_radius, vis_resize_factor, closefig, color_index, mark_index);
		hold on; plot(corresponding_lines{cluster_index}(:, [1 2])', corresponding_lines{cluster_index}(:, [3 4])', 'Color', color_set(color_index));
		hold off;

		save_path_tmp = fullfile(save_dir, sprintf('%s_VP_%d_provided.eps', image_name, cluster_index));
		print(save_path_tmp, '-depsc');
	end

	img_with_pts = visualize_image_with_pts(img, VPs, vis_mode, debug_mode, save_path, label, label_str, vis_radius, vis_resize_factor, closefig, 4, 5);	hold on;
	for cluster_index = 1:num_vp
		plot(corresponding_lines{cluster_index}(:, [1 2])', corresponding_lines{cluster_index}(:, [3 4])', 'Color', color_set(color_index), 'MarkerSize', vis_radius);
	end
	hold off;
	save_path_tmp = fullfile(save_dir, sprintf('%s_VP_all_provided.eps', image_name));
	print(save_path_tmp, '-depsc');
end

[VPs, lines_seg, line_index, corresponding_lines] = get_vanishing_points_RANSAC(img, num_vp, debug_mode, false, num_iter, error_threshold);
if vis_mode
	color_set = ['r', 'g', 'b', 'k', 'y', 'm', 'c', 'w'];
	save_path = '';
	label = false;
	label_str = '';
	vis_radius = 10;
	vis_resize_factor = 1;
	closefig = false;
	mark_index = 1;
	for cluster_index = 1:num_vp
		color_index = cluster_index;
		img_with_pts = visualize_image_with_pts(img, VPs(cluster_index, :)', vis_mode, debug_mode, save_path, label, label_str, vis_radius, vis_resize_factor, closefig, color_index, mark_index);
		hold on; plot(corresponding_lines{cluster_index}(:, [1 2])', corresponding_lines{cluster_index}(:, [3 4])', 'Color', color_set(color_index));
		hold off;

		save_path_tmp = fullfile(save_dir, sprintf('%s_VP_%d.eps', image_name, cluster_index));
		print(save_path_tmp, '-depsc');
	end

	img_with_pts = visualize_image_with_pts(img, VPs', vis_mode, debug_mode, save_path, label, label_str, vis_radius, vis_resize_factor, closefig, 4, 5);	hold on;
	for cluster_index = 1:num_vp
		plot(corresponding_lines{cluster_index}(:, [1 2])', corresponding_lines{cluster_index}(:, [3 4])', 'Color', color_set(color_index), 'MarkerSize', vis_radius);
	end
	hold off;
	save_path_tmp = fullfile(save_dir, sprintf('%s_VP_all.eps', image_name));
	print(save_path_tmp, '-depsc');
end