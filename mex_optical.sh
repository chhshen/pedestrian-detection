#!/bin/sh

echo "Compiling optical flow code."
cd Helpers/OpticalFlow/mex
mex Coarse2FineTwoFrames.cpp GaussianPyramid.cpp OpticalFlow.cpp
