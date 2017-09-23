function [ landmarks ] = find3d_landmark( A )
%find3d_landmark find 3d location of 68 facial landmarks 
% 
%   SYNTAX
%   [ landmarks ] = find3d_landmark( A )
% 
%   INPUT
%   A             - a .ply file with color(format: binary)
%                
%   OUTPUT
%   landmarks     - [x,y,z] of 68 3d facial landmarks
% 
%   REFERENCES:
%   https://github.com/YuvalNirkin/find_face_landmarks.git
% 
%   Copyright 2017, yzhang559
%   Licensed for use under Apache License, Version 2.  See LICENSE for 
%   details.

    % Matlab library for finding face landmarks of 2d image
    % from https://github.com/YuvalNirkin/find_face_landmarks.git
    addpath('C:\Users\user\Documents\MATLAB\find_face_landmarks-1.2-x64-vc14-release\interfaces\matlab');

    pt_a=pcread(A);
    color=pt_a.Color;
    [vertex,face] = readPLY(A);
    figure('units','pixels','Position',[100 100 800 800]);
    trimesh(...
            face, vertex(:, 1), vertex(:, 2), vertex(:, 3), ...
            'EdgeColor', 'none', ...
            'FaceVertexCData', color, 'FaceColor', 'interp', ...
            'FaceLighting', 'phong' ...
            ); 
    view(2)
    axis equal;
    axis vis3d;

    xlabel('x-axis')
    ylabel('y-axis')
    zlabel('z-axis')

    ax = gca;
    F = getframe(ax);
    imwrite(F.cdata,[A, '.png'])

    %%
    % 2d facial landmark detection
    modelFile = 'shape_predictor_68_face_landmarks.dat';
    I = imread([A, '.png']);
    frame = find_face_landmarks(modelFile, I);

    %%
    % convert 2d ficial landmark to 3d dimension
    column=frame.faces.landmarks(:,1);
    row=frame.faces.landmarks(:,2);

    figure(2)
    imshow(I);
    hold on
    scatter(column,row,10,'red','fill');

    % Get the image size.
    [rows, columns, ~] = size(I);
    [x3d,y3d]=to3d(rows,columns,pt_a.XLimits,pt_a.YLimits,column,row);

    % plot 3d landmarks
    figure(3)
    trimesh(...
            face, vertex(:, 1), vertex(:, 2), vertex(:, 3), ...
            'EdgeColor', 'none', ...
            'FaceVertexCData', color, 'FaceColor', 'interp', ...
            'FaceLighting', 'phong' ...
            );
    hold on 
    a1=[vertex(:,1),vertex(:,2)];
    k = dsearchn(a1,[x3d,y3d]);
    landmarks=[vertex(k,1),vertex(k,2),vertex(k,3)];
    scatter3(vertex(k,1),vertex(k,2),vertex(k,3),10,'red','fill')
    
end

