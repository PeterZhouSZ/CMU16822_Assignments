
% (Constant) ObsIdx: index of KxN for N points observed by K cameras, sparse matrix
% (Constant) ObsVal: 2xM for M observations
% K: intrinsic matrix
% Mot: 3x2xK for K cameras
% Str: 3xN for N points
function residuals = reprojectionResidual_intrinsic(ObsIdx, ObsVal, all_variable)
	nCam = size(ObsIdx,1);
    cut = 3*2*nCam;

	K = all_variable(1:9);
	Mot = all_variable(9+1:9+cut);
	Str = all_variable(9+cut+1:end);

	K = reshape(K, 3, 3);
	Mot = reshape(Mot,3,2,[]);
	Str = reshape(Str,3,[]);

	% size(Mot)
	% size(Str)

	residuals = [];
	for c=1:nCam
	    validPts = ObsIdx(c,:)~=0;
	    validIdx = ObsIdx(c,validPts);
	    
	    RP = AngleAxisRotatePts(Mot(:,1,c), Str(:,validPts));
	    % size(RP)
	    % size(Mot(:,1,c))
	    % pause;

	    TRX = RP(1,:) + Mot(1,2,c);		% 1 X num_pts
	    TRY = RP(2,:) + Mot(2,2,c);		% 1 X num_pts
	    TRZ = RP(3,:) + Mot(3,2,c);		% 1 X num_pts
	
		% size(TRX)    
	    
	    % TRXoZ = TRX./TRZ;
	    % TRYoZ = TRY./TRZ;
	    % pts = K * [TRXoZ; TRYoZ; 1];
	    pts = K * [TRX; TRY; TRZ];		% 3 X num_pts

	    % x = f*TRXoZ + px;
	    % y = f*TRYoZ + py;

	    z = pts(3, :);
	    x = pts(1, :) ./ z;
	    y = pts(2, :) ./ z;
	    
	    ox = ObsVal(1,validIdx);
	    oy = ObsVal(2,validIdx);
	    
	    residuals = [residuals [x-ox; y-oy]];    
	end

	residuals = residuals(:);
end