% Author: Xinshuo
% Email: xinshuow@andrew.cmu.edu

% If debug=1, you should provide whatever manual input (annotation) you require (e.g., marking parallel or perpendicular lines, planes etc.).
% If debug=0, you should load whatever information you manually entered and return [rectI, H].
function [rectI, H] = rectifyImage(filename, debug)
	label_mode = debug;
	check = true;

	[d, fname] = fileparts(filename);
	anno_savepath = fullfile(strrep(d, '/images', '/data'), [fname '.mat']);
	img = imread(filename);

	if debug
		%% step 1: affine rectification		
		
		% get point and visualization
		fprintf('collecting two pairs of parallel lines. Please click 8 points\n');
		fig1 = figure(1);
		imshow(img); hold on;
		pts_paral = ginput(8);
		visualize_segment(pts_paral(1:2, :), fig1, 1, check);
		visualize_segment(pts_paral(3:4, :), fig1, 1, check);
		visualize_segment(pts_paral(5:6, :), fig1, 2, check);
		visualize_segment(pts_paral(7:8, :), fig1, 2, check);
		hold off;

		% rectification
		line1_paral = get_2dline_from_pts(pts_paral(1, :), pts_paral(2, :), check);
		line2_paral = get_2dline_from_pts(pts_paral(3, :), pts_paral(4, :), check);
		line3_paral = get_2dline_from_pts(pts_paral(5, :), pts_paral(6, :), check);
		line4_paral = get_2dline_from_pts(pts_paral(7, :), pts_paral(8, :), check);
		line_pairs_paral = [line1_paral; line2_paral; line3_paral; line4_paral];
		[affine_rectified_img, H_affine] = affine_rectification(img, line_pairs_paral, check);
		H_affine

		%% step 2: metric rectification

		% get point and visualization
		fprintf('collecting two pairs of orthogonal line. Please click 8 points\n');
		fig2 = figure(2);
		imshow(affine_rectified_img);
		pts_ortho = ginput(8);
		visualize_segment(pts_ortho(1:2, :), fig2, 1, check);
		visualize_segment(pts_ortho(3:4, :), fig2, 1, check);
		visualize_segment(pts_ortho(5:6, :), fig2, 2, check);
		visualize_segment(pts_ortho(7:8, :), fig2, 2, check);
		hold off;

		% rectification
		line1_ortho = get_2dline_from_pts(pts_ortho(1, :), pts_ortho(2, :), check);
		line2_ortho = get_2dline_from_pts(pts_ortho(3, :), pts_ortho(4, :), check);
		line3_ortho = get_2dline_from_pts(pts_ortho(5, :), pts_ortho(6, :), check);
		line4_ortho = get_2dline_from_pts(pts_ortho(6, :), pts_ortho(8, :), check);
		line_pairs_ortho = [line1_ortho; line2_ortho; line3_ortho; line4_ortho];

		fprintf('save annotation to the file at %s\n', anno_savepath);
		mkdir_if_missing(fileparts(anno_savepath));
		save(anno_savepath, 'pts_paral', 'pts_paral', 'pts_ortho', 'pts_ortho', 'line_pairs_paral', 'line_pairs_paral', 'line_pairs_ortho', 'line_pairs_ortho');

		[metric_rectified_img, H_metric] = metric_rectification_affine(affine_rectified_img, line_pairs_ortho, check);

		fprintf('save annotation to the file at %s\n', anno_savepath);
		mkdir_if_missing(fileparts(anno_savepath));
		save(anno_savepath, 'pts_paral', 'pts_paral', 'pts_ortho', 'pts_ortho', 'line_pairs_paral', 'line_pairs_paral', 'line_pairs_ortho', 'line_pairs_ortho');
	else
		fprintf('evaluating based on annotations available at %s\n', anno_savepath);
		load(anno_savepath);

		% plot the annotations available
		fig1 = figure(1);
		imshow(img);	hold on;
		visualize_segment(pts_paral(1:2, :), fig1, 1, check);
		visualize_segment(pts_paral(3:4, :), fig1, 1, check);
		visualize_segment(pts_paral(5:6, :), fig1, 2, check);
		visualize_segment(pts_paral(7:8, :), fig1, 2, check);
		hold off;
		img_savepath = fullfile(strrep(d, '/images', '/output'), [fname '_original_with_annotation']);
		mkdir_if_missing(fileparts(img_savepath));
		print(img_savepath, '-depsc');

		[affine_rectified_img, H_affine] = affine_rectification(img, line_pairs_paral, check);		
		H_affine

		fig2 = figure(2);
		imshow(affine_rectified_img);	hold on;
		visualize_segment(pts_ortho(1:2, :), fig2, 1, check);
		visualize_segment(pts_ortho(3:4, :), fig2, 1, check);
		visualize_segment(pts_ortho(5:6, :), fig2, 2, check);
		visualize_segment(pts_ortho(7:8, :), fig2, 2, check);
		hold off;
		img_savepath = fullfile(strrep(d, '/images', '/output'), [fname '_affine_with_annotation']);
		print(img_savepath, '-depsc');

		[metric_rectified_img, H_metric] = metric_rectification_affine(affine_rectified_img, line_pairs_ortho, check);
		H_metric
		
		% measure orthogonality
		for line_index = 1:2
			line1_index = 1 + (line_index - 1) * 2;
			line2_index = line1_index + 1;

			cosine = angle_between_2dline(line_pairs_ortho(line1_index, :), line_pairs_ortho(line2_index, :), check);

			line_new1 = inv(H_metric)' * line_pairs_ortho(line1_index, :)';
			line_new2 = inv(H_metric)' * line_pairs_ortho(line2_index, :)';
			cosine_rectified = angle_between_2dline(line_new1', line_new2', check);
			fprintf('the cosine before and after rectification for the orthogonal lines is %.10f and %.10f\n', cosine, cosine_rectified);
		end
	end

	fig3 = figure(3);
	imshow(metric_rectified_img);
	img_savepath = fullfile(strrep(d, '/images', '/output'), [fname '_metric_rectification']);
	print(img_savepath, '-depsc');

	H = H_metric * H_affine;
	rectI = metric_rectified_img;
end