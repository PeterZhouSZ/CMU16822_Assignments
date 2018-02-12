% Author: Xinshuo Weng
% Email: xinshuo.weng@gmail.com

function visualizeReprojection(mergedGraph, frames)

	color_set = ['r', 'g', 'b', 'k', 'y', 'm', 'c', 'w'];
	marker_set = ['o', '+', '*', '.', 'x', 's', 'd', '<', '>', 'p', 'h', 'none'];
	color_index = 1;
	vis_radius = 5;
	marker_index = 1;
	% marker_tmp

	Str = mergedGraph.Str;		% 3 x num_pts
	% mot = mergedGraph.Mot;			% 3 x 4 x num_frames

	ObsIdx = mergedGraph.ObsIdx;
	ObsVal = mergedGraph.ObsVal;

	nCam=length(mergedGraph.frames);
	Mot = zeros(3,2,nCam);		% motion, first column is 3 dof rotation, second column is 3 dof translation
	for camera=1:nCam
	    Mot(:,1,camera) = RotationMatrix2AngleAxis(mergedGraph.Mot(:,1:3,camera));
	    Mot(:,2,camera) = mergedGraph.Mot(:,4,camera);
	end
	K = mergedGraph.K;

	% frames.imsize

	for c=1:nCam
		image_i = im2double(imresize(imread(frames.images{c}),frames.imsize(1:2)));

	    validPts = ObsIdx(c,:)~=0;
	    nonvalidpts = ObsIdx(c,:) == 0;
	    validIdx = ObsIdx(c,validPts);
	    
	    RP = AngleAxisRotatePts(Mot(:,1,c), Str(:,validPts));
	    TRX = RP(1,:) + Mot(1,2,c);		% 1 x num_pts
	    TRY = RP(2,:) + Mot(2,2,c);		% 1 x num_pts
	    TRZ = RP(3,:) + Mot(3,2,c);		% 1 x num_pts
	    pts = K * [TRX; TRY; TRZ];		% 3 x num_pts
	    z = pts(3, :);
	    x = pts(1, :) ./ z;
	    y = pts(2, :) ./ z;
		x = -x + size(image_i,2)/2;
		y = -y + size(image_i,1)/2;


	    RP = AngleAxisRotatePts(Mot(:,1,c), Str(:,nonvalidpts));
	    TRX = RP(1,:) + Mot(1,2,c);		% 1 x num_pts
	    TRY = RP(2,:) + Mot(2,2,c);		% 1 x num_pts
	    TRZ = RP(3,:) + Mot(3,2,c);		% 1 x num_pts
	    pts = K * [TRX; TRY; TRZ];		% 3 x num_pts
	    z_non = pts(3, :);
	    x_non = pts(1, :) ./ z_non;
	    y_non = pts(2, :) ./ z_non;
		x_non = -x_non + size(image_i,2)/2;
		y_non = -y_non + size(image_i,1)/2;


	    ox = ObsVal(1,validIdx);
	    oy = ObsVal(2,validIdx);

		ox = -ox + size(image_i,2)/2;
		oy = -oy + size(image_i,1)/2;

	    pts_array = [x; y];
		fig = figure; imshow(image_i); hold on;
		
		color_index = 2;
		marker_index = 2;
		marker_tmp = marker_set(marker_index);
		color_tmp = color_set(color_index);
		plot(x, y, 'o', 'Color', color_tmp, 'MarkerSize', vis_radius, 'MarkerFaceColor', color_tmp, 'Marker', marker_tmp);

		color_index = 5;
		marker_index = 1;
		marker_tmp = marker_set(marker_index);
		color_tmp = color_set(color_index);
		plot(x_non, y_non, 'o', 'Color', color_tmp, 'MarkerSize', vis_radius, 'Marker', marker_tmp);

		color_index = 1;
		marker_index = 5;
		marker_tmp = marker_set(marker_index);
		color_tmp = color_set(color_index);
		plot(ox, oy, 'o', 'Color', color_tmp, 'MarkerSize', vis_radius, 'MarkerFaceColor', color_tmp, 'Marker', marker_tmp);
		
		color_index = 3;
		marker_index = 12;
		num_pts = size(x, 2);
		for pts_index = 1:num_pts
			line_segment = [x(pts_index), y(pts_index); ox(pts_index), oy(pts_index)];
			visualize_segment(line_segment, fig, color_index, marker_index, false);
		end

		hold off
		print(sprintf('results/image_%05d.eps', c), '-depsc');
		pause(1);
		close(fig);
	end

end






% Author: Xinshuo Weng
% email: xinshuo.weng@gmail.com

% visualize a heatmap on top of an image
function visualize_segment(pts_array, fig, color_index, marker_index, debug_mode)
    if nargin < 5
        debug_mode = true;
    end

    marker_set = ['o', '+', '*', '.', 'x', 's', 'd', '<', '>', 'p', 'h', 'none'];
    color_set = ['r', 'g', 'b', 'y', 'm', 'c', 'w', 'k'];

    if debug_mode
        assert(all(size(pts_array) == [2, 2]), 'the input point array is not correct');
    end

	marker_tmp = marker_set(marker_index);
    % figure(fig);
    plot(pts_array(:, 1), pts_array(:, 2), 'Marker', marker_tmp, 'Color', color_set(color_index));
end
