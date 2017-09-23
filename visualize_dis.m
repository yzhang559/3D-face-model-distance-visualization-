function [ point2point, point2plane ] = visualize_dis(moving,fixed,showpercentage)
% visualize_dis visualize the point-to-point distance and point-to-plane
% distance of 2 3d pointCloud, as well as the histogram of those 2 kinds of 
% distance. It can be used to evaluate the accuracy of 3d reconstruction. 
%   
%   SYNTAX
%   [ point2point, point2plane ] = visualize_dis(moving,fixed,showpercentage)
% 
%   INPUT
%   moving        - pointCloud Object for storing a 3-D point cloud.
%   ptCloud = pointCloud(xyzPoints) creates a point cloud object whose
%   coordinates are specified by an M-by-3 or M-by-N-by-3 matrix xyzPoints.
%                 
% 
%   fixed         - pointCloud Object for storing a 3-D point cloud.
%                   Usually, this one has more points than moving
%                 
% 
%   OUTPUT
%   point2point   - M-by-1 point-to-point distance
%   point2plane   - M-by-1 point-to-plane distance
% 
%   REFERENCES:
%   pcregrigid function from Point Cloud Processing toolbox
% 
%   Copyright 2017, yzhang559
%   Licensed for use under Apache License, Version 2.  See LICENSE for 
%   details.



    % A copy of the input with unorganized M-by-3 data
    ptCloudA = removeInvalidPoints(moving);
    [ptCloudB, validPtCloudIndices] = removeInvalidPoints(fixed);

    % At least three points are needed to determine a 3-D transformation
    if ptCloudA.Count < 3 || ptCloudB.Count < 3
        error(message('vision:pointcloud:notEnoughPoints'));
    end

    % Compute the unit normal vector if it is not provided.
    if isempty(fixed.Normal)
        fixedCount = fixed.Count;
        % Use 6 neighboring points to estimate a normal vector. You may use
        % pcnormals with customized parameter to compute normals upfront.
        fixed.Normal = surfaceNormalImpl(fixed, 6);        
        ptCloudB.Normal = [fixed.Normal(validPtCloudIndices), ...
                           fixed.Normal(validPtCloudIndices + fixedCount), ...
                           fixed.Normal(validPtCloudIndices + fixedCount * 2)];
    end
    upperBound = ptCloudA.Count;    
    % Remove points if their normals are invalid
    tf = isfinite(ptCloudB.Normal);
    validIndices = find(sum(tf, 2) == 3);
    if numel(validIndices) < ptCloudB.Count
        [loc, ~, nv] = subsetImpl(ptCloudB, validIndices);
        ptCloudB = pointCloud(loc, 'Normal', nv);
        if ptCloudB.Count < 3
            error(message('vision:pointcloud:notEnoughPoints'));
        end
    end
    
    locA=ptCloudA.Location;
    % Find the correspondence
    [indices, dists] = multiQueryKNNSearchImpl(ptCloudB, locA, 1);

    % Remove outliers
    keepInlierA = false(ptCloudA.Count, 1); 
    [~, idx] = sort(dists);
    keepInlierA(idx(1:upperBound)) = true;
    inlierIndicesA = find(keepInlierA);
    inlierIndicesB = indices(keepInlierA);
    % inlierDist = dists(keepInlierA);
    
    if numel(inlierIndicesA) < 3
        error(message('vision:pointcloud:notEnoughPoints'));
    end
    
    % calculate 2 kinds of distance for all points 
    point2point=sqrt(sum((locA( inlierIndicesA, :) - ptCloudB.Location( inlierIndicesB, :)).^2,2)); 
    point2plane=sqrt(dot(locA(inlierIndicesA, :)-ptCloudB.Location(inlierIndicesB, :),ptCloudB.Normal(inlierIndicesB, :),2).^2);
     
    %% display 2 kinds of distance (selected percentage: 0-1)
    fulllength=length(idx);
    k=round(showpercentage*fulllength);
    showidx = false(k, 1); 
    showidx(idx((upperBound-k+1):upperBound))=true;
    showA=find(showidx);
    showB=indices(showidx);
    xyz=ptCloudB.Location(showB',:);
    
    % point-to-point distance
    subplot(1,2,1)
    pcshowpair(ptCloudB,ptCloudA);
    hold on
    x=[xyz(:,1),ptCloudA.Location( showA,1)];
    y=[xyz(:,2),ptCloudA.Location( showA,2)];
    z=[xyz(:,3),ptCloudA.Location( showA,3)];
    plot3(x',y',z','b-');
    title('point to point distance')
   
    % point-to-plane distance
    subplot(1,2,2)
    pcshowpair(ptCloudB,ptCloudA);  
    point2plane_dis=sqrt(dot(locA(showA', :)-ptCloudB.Location(showB', :),ptCloudB.Normal(showB', :),2).^2);
    uvw=locA(showA',:);
    partial_norm=ptCloudB.Normal(showB',:);
    scale=[point2plane_dis,point2plane_dis,point2plane_dis];
    scale_n=partial_norm.*scale;
    hold on
    u=[uvw(:,1),uvw(:,1)+ scale_n(:,1)];
    v=[uvw(:,2),uvw(:,2)+ scale_n(:,2)];
    w=[uvw(:,3),uvw(:,3)+ scale_n(:,3)];
    plot3(u',v',w','b-');
    title('point to plane distance')
    
    %% histogram
    figure(2)
    
    subplot(1,2,1)
    h1= histogram(point2point);
    hold on
    % calculate the selected percentage of distance(point-to-point)
    partial_dis=sqrt(sum((locA(showA, :) - ptCloudB.Location(showB, :)).^2,2));
    h2 = histogram(partial_dis);
    h2.BinWidth=h1.BinWidth;
    title('point to point distance hist')
    
    subplot(1,2,2)
    h3= histogram(point2plane);
    h3.BinWidth=h1.BinWidth;
    h3. BinLimits=h1.BinLimits;
    title('point to plane distance hist')
    
end

