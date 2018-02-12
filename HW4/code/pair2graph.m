function graph=pair2graph(pair,frames)

graph = pair;

pointCount = size(pair.matches,2);			% num_pts

% graph.f   = frames.focal_length;
graph.K = frames.K;

graph.Mot(:,:,1) = [eye(3) [0;0;0]];
graph.Mot(:,:,2) = pair.Rt;

graph.Str   = zeros(3,pointCount);

graph.ObsVal = [pair.matches(1:2,:) pair.matches(3:4,:)];


% [1:pointCount; pointCount + (1:pointCount)]
% pause

graph.ObsIdx = sparse([1:pointCount; pointCount + (1:pointCount)]);				% 2 x num_pts

graph.num_match = pointCount;