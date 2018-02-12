% Author: Xinshuo
% Email: xinshuow@andrew.cmu.edu

clc;
clear('all');
close all;

startup();
debug_mode = true;
vis_mode = true;
save_dir = './results/q2_1';
mkdir_if_missing(save_dir);

num_vp = 3;
num_iter = 50000; 		% for RANSAC
error_threshold = 50;	% threshold for counting the example within the inlier set
rng(1);

image_name = 'a6';
img = sprintf('./images/input/%s.jpg', image_name);
assert(exist(img, 'file') ~= 0, 'the image does not exist');

img = imread(img);
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