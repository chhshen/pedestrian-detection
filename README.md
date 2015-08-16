- Pedestrian Detection

This code produces the results presented in
<http://arxiv.org/abs/1409.5209>
on the Caltech dataset (optical flow used; so it doesn't work on the INRIA dataset)
with BING as the pre-processor.





If you use this code in your research, please cite our papers:

```
@inproceedings{PaisitkriangkraiSH14a,
   author              = {Sakrapee Paisitkriangkrai and
                          Chunhua Shen and
                          Anton {van den Hengel}},
   title               = {Strengthening the Effectiveness of Pedestrian Detection with Spatially Pooled Features},
   booktitle           = {Proc. European Conf. Comp. Vis.},
   year                = {2014},
   ee                  = {http://arxiv.org/abs/1407.0786},
}
```


```
@inproceedings{PaisitkriangkraiSH14b,
   author              = {Sakrapee Paisitkriangkrai and
                          Chunhua Shen and
                          Anton van den Hengel},
   title               = {Pedestrian Detection with Spatially Pooled Features and Structured Ensemble Learning},
   journal             = {IEEE Transactions on Pattern Analysis and Machine Intelligence},
   year                = {2015},
   ee                  = {http://arxiv.org/abs/1409.5209},
}
```



- The current demo contains a few test images from Caltech Pedestrian data sets
(set07, V004).

- (a) Compile optical flow source code if needed by (Precompiled files provided already! You may not need to compile your own version)

`	sh> ./mex_optical.sh`

- (b) Run demo.m (This will generate the ROC curve on the Caltech dataset set07, V004. It will download the data first ~400M.)

`	matlab> demo`

__WARNING: It may take 2 to 4 hours to get the result, depending on your machine.__ You should see a plot as below.


- More Caltech Pedestrian test data can be obtained from

<http://www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/datasets/USA/>

- NB: set00-set05 are used for training and set06-set10 are used for testing
       see <http://www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/>

- The data set is in seq video format. Download MATLAB functions for read/write
       seq video files from <http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html>


The code has been tested to run on Ubuntu 14.04LTS (kernel: Linux 3.13.0-39-generic #66-Ubuntu SMP x86_64 GNU/Linux),
Matlab 2013a.


![ROC curve](https://github.com/chhshen/pedestrian-detection/blob/master/roc.png "ROC curve")

