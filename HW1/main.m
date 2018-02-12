% Author: Xinshuo
% Email: xinshuow@andrew.cmu.edu

clc;
clear('all');
close all;

startup();

image_name = 'tiles2';
img = sprintf('./images/%s.jpg', image_name);
assert(exist(img, 'file') ~= 0, 'the image does not exist');

annotation_path = sprintf('./data/%s.mat', image_name);

% annotation
if exist(annotation_path, 'file') == 0
	debug = true;
	rectifyImage(img, debug);
end

% rectification
debug = false;
rectifyImage(img, debug);