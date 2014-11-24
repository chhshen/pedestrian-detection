- Pedestrian Detection

This code produces the results presented in
<http://arxiv.org/abs/1409.5209>
on the Caltech dataset (optical flow used; so it doesn't work on the INRIA dataset)
with BING as the pre-processor.



- The current demo contains a few test images from Caltech Pedestrian data sets
(set07, V004).

-- 1. Compile optical flow source code by
`	-sh> ./Compile.sh`

-- 2. Run demo.m
`	-matlab> demo`

- More Caltech Pedestrian test data can be obtained from

<http://www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/datasets/USA/>

- NB: set00-set05 are used for training and set06-set10 are used for testing
       see <http://www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/>

- The data set is in seq video format. Download MATLAB functions for read/write
       seq video files from <http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html>


__Tested on Linux (Ubuntu 10.04), Matlab 2013a__
