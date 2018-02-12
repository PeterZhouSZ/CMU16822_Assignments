% Author: Xinshuo
% Email: xinshuow@andrew.cmu.edu

clc;
clear('all');
close all;

startup();
run('vlfeat/toolbox/vl_setup');

seed = 1
rng(seed);
debug_mode = false;
vis_mode = true;
max_iter = 100000;
error_threshold = 0.05;
num_planes = 2;
data_path = './data';
save_dir = './results/q3_1';
mkdir_if_missing(data_path);
mkdir_if_missing(save_dir);

image1_name = '3_001';
image2_name = '3_002';
img1_file = sprintf('./images/input/%s.jpg', image1_name);
img2_file = sprintf('./images/input/%s.jpg', image2_name);
assert(exist(img1_file, 'file') ~= 0, 'the image does not exist');
assert(exist(img2_file, 'file') ~= 0, 'the image does not exist');

img1 = imread(img1_file);
img2 = imread(img2_file);

im_height = size(img1, 1);
im_width = size(img1, 2);
im_channel = size(img1, 3);
assert(im_width == size(img2, 2), 'width is not equal');
assert(im_height == size(img2, 1), 'height is not equal');
assert(im_channel == size(img2, 3), 'channel is not equal');
normalize_factor = max(im_height, im_width);

% get point correspondences
fprintf('\n\n**********************************finding point correspondences......\n\n');
[fa, da] = vl_sift(single(rgb2gray(img1)));
[fb, db] = vl_sift(single(rgb2gray(img2)));
pts1 = fa(1:2, :); 		% normalized pts, 2 x num_pts
pts2 = fb(1:2, :);
fprintf('%d interest points are found in the first image.\n', size(pts1, 2));
fprintf('%d interest points are found in the second image.\n', size(pts2, 2));
assert(all(pts1(1, :) < im_width), 'the point is outside of width');
assert(all(pts1(2, :) < im_height), 'the point is outside of height');
assert(all(pts2(1, :) < im_width), 'the point is outside of width');
assert(all(pts2(2, :) < im_height), 'the point is outside of height');

[matches, scores] = vl_ubcmatch(da, db);		% match 2 x num_correspondence, 	score 1 x num_correspondence

pts1_matched = pts1(:, matches(1, :));			% 2 x num_pts
pts2_matched = pts2(:, matches(2, :));
fprintf('%d interest points are matched between two images.\n', size(pts1_matched, 2));

fprintf('\n\n**********************************auto-calibration......\n\n');
% K = autocalibrate({img1_file; img2_file}, debug_mode, data_path);
K1 = autocalibrate({img1_file}, debug_mode, data_path);
K2 = autocalibrate({img2_file}, debug_mode, data_path);

fprintf('\n\n**********************************estimating essential and projection matrix......\n\n');
% [F, inliersIndex] = compute_F_from_pts_correspondence(pts1_matched', pts2_matched', normalize_factor, debug_mode);
[F, inliersIndex] = estimateFundamentalMatrix(pts1_matched', pts2_matched');

inliersIndex = find(inliersIndex);
pts1_inlier = pts1_matched(:, inliersIndex);				% 2 x num_pts
pts2_inlier = pts2_matched(:, inliersIndex);
fprintf('%d point correspondences are used for estimating fundamental matrix\n', length(inliersIndex));

img_merged = zeros(im_height, im_width * 2, im_channel);
img_merged(:, 1:im_width, :) = im2double(img1);	
img_merged(:, im_width+1:end, :) = im2double(img2);
pts1_vis = pts1_inlier; 
pts2_vis = pts2_inlier; pts2_vis(1, :) = pts2_vis(1, :) + im_width;

save_correspondece = fullfile(save_dir, sprintf('point_correspondence_%s_%s.eps', image1_name, image2_name));
visualize_image_with_pts(img_merged, [pts1_vis, pts2_vis], vis_mode, debug_mode, '', false); hold on;
plot([pts1_vis(1, :); pts2_vis(1, :)], [pts1_vis(2, :); pts2_vis(2, :)]);
print(save_correspondece, '-depsc');
hold off;

E = compute_E_from_F_calibrated(F, K1, K2, debug_mode);
M1 = compute_M(K1, eye(3), [0; 0; 0]);
M2 = compute_M_from_E_pts_correspondence(E, pts1_inlier, pts2_inlier, K1, K2, debug_mode);


fprintf('\n\n**********************************reconstruction and plane segmentation......\n\n');
% triangulation
[pts_3d, err] = triangulate(pts1_inlier, pts2_inlier, M1, M2);		% nun_pts x 3

% plane segmentation in 3D
save_recons = fullfile(save_dir, sprintf('reconstruction_%s_%s.eps', image1_name, image2_name));
[planes, pts_index_plane, corresponding_pts] = get_dominant_3dplane_RANSAC(pts_3d, num_planes, debug_mode, vis_mode, save_recons, max_iter, error_threshold);

fprintf('\n\n**********************************visualization......\n\n');
color_set = ['r', 'g', 'b', 'k', 'y', 'm', 'c', 'w'];

% visualize the plane in the first image
fig = figure; imshow(img1); hold on;
save_plane = fullfile(save_dir, sprintf('plane_segmentation_%s_%s_image1.eps', image1_name, image2_name));
color_index = 1;
for plane_index = 1:num_planes
	pts_3d_tmp = corresponding_pts{plane_index};							% num_pts x 3
	pts_2d_tmp = projection_from_pts(pts_3d_tmp', M1, debug_mode);				% 2 x num_pts
	scatter(pts_2d_tmp(1, :), pts_2d_tmp(2, :), 'MarkerFaceColor', color_set(color_index));
	color_index = color_index + 1;
	pts_tmp = get_convex_hull(pts_2d_tmp');
	plot(pts_tmp(1, :), pts_tmp(2, :));  % to plot polygon
	fill(pts_tmp(1, :), pts_tmp(2, :), color_set(color_index));  % to fill the polygon
	transparency = 0.3;  % values between 0 and 1
	alpha(transparency);
end
print(save_plane, '-depsc');
hold off; 

% visualize the plane in the second image
fig = figure; imshow(img2); hold on;
save_plane = fullfile(save_dir, sprintf('plane_segmentation_%s_%s_image2.eps', image1_name, image2_name));
color_index = 1;
for plane_index = 1:num_planes
	pts_3d_tmp = corresponding_pts{plane_index};							% num_pts x 3
	pts_2d_tmp = projection_from_pts(pts_3d_tmp', M2, debug_mode);				% 2 x num_pts
	scatter(pts_2d_tmp(1, :), pts_2d_tmp(2, :), 'MarkerFaceColor', color_set(color_index));
	color_index = color_index + 1;
	pts_tmp = get_convex_hull(pts_2d_tmp');
	plot(pts_tmp(1, :), pts_tmp(2, :));  % to plot polygon
	fill(pts_tmp(1, :), pts_tmp(2, :), color_set(color_index));  % to fill the polygon
	transparency = 0.3;  % values between 0 and 1
	alpha(transparency);
end
print(save_plane, '-depsc');
hold off;