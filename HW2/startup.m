% Author: Xinshuo
% Email: xinshuow@andrew.cmu.edu

function startup()
	libdir = fileparts(mfilename('fullpath'));
	addpath(genpath(fullfile(libdir, 'lib', 'lineCodes', 'derekhoiem')));
	addpath(genpath(fullfile(libdir, 'lib', 'hedauvp')));
	addpath(genpath(fullfile(libdir, 'lib', 'vlfeat')));

	addpath(genpath(fullfile(libdir, 'xinshuo_toolbox', 'xinshuo_vision', 'geometry')));
	addpath(genpath(fullfile(libdir, 'xinshuo_toolbox', 'xinshuo_visualization')));
	addpath(genpath(fullfile(libdir, 'xinshuo_toolbox', 'xinshuo_matlab', 'check')));
	addpath(genpath(fullfile(libdir, 'xinshuo_toolbox', 'xinshuo_io')));
	addpath(genpath(fullfile(libdir, 'xinshuo_toolbox', 'xinshuo_math')));
	addpath(genpath(fullfile(libdir, 'xinshuo_toolbox', 'external', 'computer_vision', 'kmeans_meanshift_normalizedcut')));
end