function graph = bundleAdjustment(graph, adjust_type)
	if nargin < 2
		% adjust_type = 's+m';		% both, all, motion, structure
		assert(false, 'error');
	end

	% convert from Rt matrix to AngleAxis
	nCam=length(graph.frames);
	Mot = zeros(3,2,nCam);		% motion, first column is 3 dof rotation, second column is 3 dof translation
	for camera=1:nCam
	    Mot(:,1,camera) = RotationMatrix2AngleAxis(graph.Mot(:,1:3,camera));
	    Mot(:,2,camera) = graph.Mot(:,4,camera);
	end


	Str = graph.Str;			% structure
	% f  = graph.f;

	% assume px, py=0
	K = graph.K;
	px = K(1, 3);
	py = K(2, 3);
	f = (K(1, 1) + K(2, 2))/2.0;


	residuals = reprojectionResidual(graph.ObsIdx,graph.ObsVal,px,py,f,Mot,Str);
	fprintf('initial error = %f\n', 2*sqrt(sum(residuals.^2)/length(residuals)));

	% bundle adjustment using lsqnonlin in Matlab (Levenberg-Marquardt)
	options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','Display','off');

	% adjust structure [for homework]
	if strcmp(adjust_type, 'structure')
		fprintf('adjust structure only\n');
		[vec,resnorm,residuals,exitflag] = lsqnonlin(@(x) reprojectionResidual(graph.ObsIdx,graph.ObsVal,px,py,f,Mot(:),x), [Str(:)], [], [], options);
		Str = reshape(vec,3,[]); 
		fprintf('error = %f\n', 2*sqrt(resnorm/length(residuals)));
	

	% adjust motion [for homework]
	elseif strcmp(adjust_type, 'motion')
		fprintf('adjust motion only\n');
		[vec,resnorm,residuals,exitflag] = lsqnonlin(@(x) reprojectionResidual(graph.ObsIdx,graph.ObsVal,px,py,f,x,Str(:)), Mot(:), [], [], options);
		% [Mot,Str] = unpackMotStrf(nCam,vec);
		Mot = reshape(vec,3,2,[]);
		fprintf('error = %f\n', 2*sqrt(resnorm/length(residuals)));

	% graph.ObsIdx				% 2 x num_pts, id of point correspondences
	% graph.ObsVal				% 2 x num_pts
	% pause;

	elseif strcmp(adjust_type, 's+m')
	% adjust motion and structure
		[vec,resnorm,residuals,exitflag] = lsqnonlin(@(x) reprojectionResidual(graph.ObsIdx,graph.ObsVal,px,py,f,x), [Mot(:); Str(:)],[],[],options);
		% size(vec)
		[Mot,Str] = unpackMotStrf(nCam,vec);
		fprintf('error = %f\n', 2*sqrt(resnorm/length(residuals)));

	elseif strcmp(adjust_type, 'focal')
	    % adjust focal length, motion and structure
	    [vec,resnorm,residuals,exitflag] = lsqnonlin(@(x) reprojectionResidual(graph.ObsIdx,graph.ObsVal,px,py,x), [f; Mot(:); Str(:)],[],[],options);
	    [Mot,Str,f] = unpackMotStrf(nCam,vec);
		fprintf('error = %f\n', 2*sqrt(resnorm/length(residuals)));
	    % graph.f = f;
	    K(1, 1) = f;
	    K(2, 2) = f;

	elseif strcmp(adjust_type, 'all')
		[vec,resnorm,residuals,exitflag] = lsqnonlin(@(x) reprojectionResidual_intrinsic(graph.ObsIdx,graph.ObsVal,x), [K(:); Mot(:); Str(:)],[],[],options);
		% [Mot,Str,f] = unpackMotStrf(nCam,vec);
		fprintf('error = %f\n', 2*sqrt(resnorm/length(residuals)));
		% graph.f = f;
	    cut = 3*2*nCam;
		K = vec(1:9);
		Mot = vec(9+1:9+cut);
		Str = vec(9+cut+1:end);

		K = reshape(K, 3, 3);
		Mot = reshape(Mot,3,2,[]);
		Str = reshape(Str,3,[]);

	else
		assert(false, 'Error, the adjust type should be [structure, motion, s+m, focal+s+m, all]');

	end

	%residuals = reprojectionResidual(graph.ObsIdx,graph.ObsVal,px,py,f,Mot,Str);
	%fprintf('final error = %f\n', 2*sqrt(sum(residuals.^2)/length(residuals)));


	for camera=1:nCam
	    graph.Mot(:,:,camera) = [AngleAxis2RotationMatrix(Mot(:,1,camera))  Mot(:,2,camera)];    
	end
	graph.Str = Str;
	graph.K = K;
end

