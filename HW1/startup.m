% Author: Xinshuo
% Email: xinshuow@andrew.cmu.edu

function startup()
	libdir = fileparts(mfilename('fullpath'));
	addpath(genpath(fullfile(libdir, 'lib')));
	% addpath(genpath(fullfile(libdir, 'xinshuo_toolbox', 'matlab')));
	% addpath(genpath(fullfile(libdir, 'xinshuo_toolbox', 'file_io')));
	% addpath(genpath(fullfile(libdir, 'xinshuo_toolbox', 'math')));
	% addpath(genpath(fullfile(libdir, 'xinshuo_toolbox', 'visualization')));
	% addpath_recurse(fullfile(libdir, 'xinshuo_toolbox', 'computer_vision'));
end