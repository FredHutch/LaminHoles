# LaminHoles
Quantification of gaps in the nuclear envelope

The LaminHoles repository contains a series of MATLAB functions and apps used to identify and to quantify gaps in the nuclear envelope of cells from 3D image datasets. The collected metrics pertain to properties of the nucleus (Volume, surface area, principal axes lengths, Lamin mean intensity) and of the associated gaps/holes if any (volume, centroid location, mean nuclear curvature at the gap location). Gaps on the nuclear envelope are detected using the “rays of light” algorithm (See Documentation for details).

The `LaminAnalyzerClean.mlapp` app deploys a Graphic User Interface that allows the user to interact with an image set. Once the dataset is loaded, the user can select a nucleus of interest and quantify any associated gaps with just a couple of clicks. Interactive 3D viewers of the nucleus, the gaps and the combination of both as well as a summary result table enable the user to easily explore the data. The user also has the possibility to export the associated data in a .csv file and 3D renderings in .png (static) or .gif (animated) files.

Image batch processing can be performed by running the `LaminHolesBatch.m` script.

