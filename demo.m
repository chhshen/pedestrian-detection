function demo
addpath(genpath('./Helpers'));

IMG0_DIR = './test_images/images0/';
IMG1_DIR = './test_images/images1/';

files0 = dir([IMG0_DIR,'*.jpg']);
files1 = dir([IMG1_DIR,'*.jpg']);

for i=1:length(files0)
    demo1([IMG0_DIR,files0(i).name],[IMG1_DIR,files1(i).name]);
end



function demo1(TEST_IMAGE_0, TEST_IMAGE_1)

MODEL_SIZE     = [50 20.5];
IMAGE_SIZE     = [480 640];
NUM_OCTAVE     = 8;
MODEL_FILENAME = 'model.mat';
STRIDE         = 4;
BING_THRESH    = 0.016;
PED_THRESH     = 0.1;

%
% Load BING and pedestrain detector models
%
if ~exist(MODEL_FILENAME, 'file'), return;
else  model = load(MODEL_FILENAME); ped_model=model.ped_model; bing_model=model.bing_model; end

%
% Compute optical flow between two consecutive images
%
batch = 70;
alpha = 0.01;
ratio = 0.8;
minWidth = 20;
nOuterFPIterations = 3;
nInnerFPIterations = 1;
nSORIterations = 20;
flowThreshold = 20;
para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

im0 = imread(TEST_IMAGE_0); im1 = imread(TEST_IMAGE_1);
if ~isequal([size(im0,1),size(im0,2)], IMAGE_SIZE),
    im0 = imresize(im0, IMAGE_SIZE);
    im1 = imresize(im1, IMAGE_SIZE);
end
tic,
[vx,vy,~] = Coarse2FineTwoFrames(im0, im1, para);
t=toc; fprintf('Extracting optical flow took: %.2f secs\n', t);
flow = cat(3,vx,vy);    
flow=min(flowThreshold, flow); flow=max(-flowThreshold,flow);
flow=single(flow./flowThreshold); % flow image (single)
I   = im2single(im0);  % test image (single)
Iuint8 = im0;          % test image (uint8)


% Pre-compute BING masks at different scales
tic,
bing = evalBINGMex(Iuint8,bing_model); bing = bing(24:-1:1); 
t=toc; fprintf('Applying BING took: %.2f secs\n', t);

imageSize = [size(I,1),size(I,2)];
nScales = floor(NUM_OCTAVE*(log2(min(imageSize./MODEL_SIZE)))+1);
scales = 2.^(-(0:nScales-1)/NUM_OCTAVE);
bbs = cell(nScales,1);
tic,
for i=1:nScales
    if i>length(bing), continue; end
    sc=scales(i); sc2=size(bing{i})*4;
    I1=imresize(I,sc2,'bilinear'); flow1=imresize(flow,sc2,'bilinear');
    bb=detectPedMex(I1,flow1,bing{i},ped_model,STRIDE,PED_THRESH,BING_THRESH);
    if ~isempty(bb), bb(:,1:4)=bb(:,1:4)./sc; bbs{i}=bb; end
end
t=toc; fprintf('Applying pedestrian detector took: %.2f secs\n', t);
bbs=cat(1,bbs{:});
bbs=bbNms(bbs,'type','maxg','overlap',0.65,'ovrDnm','min');
figure(1); imagesc(I); bbApply('draw',bbs); pause(.5);
