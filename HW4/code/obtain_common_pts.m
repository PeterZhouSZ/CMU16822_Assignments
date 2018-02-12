function num_pts_common = obtain_common_pts(GraphA,GraphB)

num_pts_common = 0;

commonFrames = intersect(GraphA.frames,GraphB.frames);

[newFramesFromB,indexNewFramesFromB] = setdiff(GraphB.frames,GraphA.frames);

if isempty(commonFrames)
    GraphAB = [];
    return;
end

GraphAB = GraphA;

if isempty(newFramesFromB)
    return;
end


% add the non-overlapping frame first
firstCommonFrame = commonFrames(1);


% transform GraphB.Mot and GraphB.Str to be in the same world coordinate system of GraphA
RtBW2AW = concatenateRts(inverseRt(GraphA.Mot(:,:,GraphA.frames==firstCommonFrame)), GraphB.Mot(:,:,GraphB.frames==firstCommonFrame));
GraphB.Str = transformPtsByRt(GraphB.Str, RtBW2AW);
for i=1:length(GraphB.frames)
    GraphB.Mot(:,:,i) = concatenateRts(GraphB.Mot(:,:,i), inverseRt(RtBW2AW));
end

GraphAB.frames = [GraphA.frames newFramesFromB];
GraphAB.Mot(:,:,length(GraphA.frames)+1:length(GraphAB.frames)) = GraphB.Mot(:,:,indexNewFramesFromB);

% add the new tracks

for commonFrame = commonFrames
    
    cameraIDA = find(GraphA.frames==commonFrame);   cameraIDB = find(GraphB.frames==commonFrame);
    
    trA = find(GraphA.ObsIdx(cameraIDA,:)~=0);
    xyA = GraphA.ObsVal(:,GraphA.ObsIdx(cameraIDA,trA));
    
    trB = find(GraphB.ObsIdx(cameraIDB,:)~=0);
    xyB = GraphB.ObsVal(:,GraphB.ObsIdx(cameraIDB,trB));

    [xyCommon,iA,iB] = intersect(xyA',xyB','rows');
    xyCommon = xyCommon';
    
    num_pts_common = length(xyCommon);
    
end