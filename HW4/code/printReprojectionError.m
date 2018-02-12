% Author: Xinshuo Weng
% Email: xinshuo.weng@gmail.com

function proj_error = printReprojectionError(graph)
	% convert from Rt matrix to AngleAxis
	nCam=length(graph.frames);
	Mot = zeros(3,2,nCam);		% motion, first column is 3 dof rotation, second column is 3 dof translation
	for camera=1:nCam
	    Mot(:,1,camera) = RotationMatrix2AngleAxis(graph.Mot(:,1:3,camera));
	    Mot(:,2,camera) = graph.Mot(:,4,camera);
	end

	Str = graph.Str;			% structure

	K = graph.K;
	
	% px = K(1, 3);
	% py = K(2, 3);
	% f = (K(1, 1) + K(2, 2))/2.0;
	% residuals = reprojectionResidual(graph.ObsIdx, graph.ObsVal, px, py, f, Mot, Str);

	residuals = reprojectionResidual_intrinsic(graph.ObsIdx, graph.ObsVal, [K(:); Mot(:); Str(:)]);


	% proj_error = 0;
	proj_error = sqrt(sum(residuals.^2) / length(residuals));
	fprintf('The reprojection error is %f\n', proj_error);
end