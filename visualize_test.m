
clc;
% load the 3d pointCloud
pt_g=pcread('groundtruth.ply');
pt_r=pcread('reconstruction.ply');

% initially align two 3d pointCloud using icp or other algorithm
% visualize the distance, show 20% largest distance
[d_p2point,d_p2plane]=visualize_dis(pt_r,pt_g,0.2);