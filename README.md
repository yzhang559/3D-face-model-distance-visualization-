# 3D-face-model-distance-visualization-
Visualize the point-to-point distance and point-to-plane  distance of two 3d pointCloud

# Find 3d facial landmark 
|frontal view            |  3d view                    |
:-------------------------:|:-------------------------:
|![](https://github.com/yzhang559/3D-face-model-distance-visualization-/blob/master/img/landmark1.jpg)  |  ![](https://github.com/yzhang559/3D-face-model-distance-visualization-/blob/master/img/landmark3d.jpg)|


Load the 3d model ply file to get the 3d location of facial landmarks.

The model cannot be distributed, from: [ http://faces.cs.unibas.ch/bfm/?nav=1-0&id=basel_face_mode ]

# visualize the p2point distance and p2plane distance
|two 3d face pointCloud with different vertexes|
:-------------------------:
|![](https://github.com/yzhang559/3D-face-model-distance-visualization-/blob/master/img/2face.png)

Call the function visualize_dis [ pt1, pt2, percentage ] to show the distance
![](https://github.com/yzhang559/3D-face-model-distance-visualization-/blob/master/img/distance.jpg)

Also, the histogram of distance can be showed as :
![](https://github.com/yzhang559/3D-face-model-distance-visualization-/blob/master/img/histogram.jpg)
