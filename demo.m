%
% Plot ROC curve on Caltech
%

function demo

matlabpool open
addpath(genpath('./Helpers'));


if ~exist('test_images', 'dir')
    % url='http://cs.adelaide.edu.au/~paulp/Caltech_test.zip';
    url='https://bitbucket.org/chhshen/data/src/56e66a9e7fa0d5ab6126720a00d05b93d2725dcb/Caltech_test_images.zip?at=master'
    fprintf('Downloading Caltech.USA test images ...\n');
    unzip(url, './');
    fprintf('Download completed ...\n');
end



IMG0_DIR = './test_images/images0/';
IMG1_DIR = './test_images/images1/';


setids = 6:10;
vids = 0:19;


fprintf('Evaluate Caltech.USA test images ...\n');
for sid = setids
    for vid = vids

        files0 = dir(sprintf('%s/set%02d_V%03d_*.jpg',IMG0_DIR,sid,vid));
        files1 = dir(sprintf('%s/set%02d_V%03d_*.jpg',IMG1_DIR,sid,vid));
        res = cell(length(files0),1);
        parfor i=1:length(files0)
            fprintf('Processing %s\n', [IMG0_DIR,files0(i).name]);
            dat =  demo1([IMG0_DIR,files0(i).name],[IMG1_DIR,files1(i).name]);
            IfileID = str2double(files0(i).name(13:17));
            dat = [repmat(IfileID+1,size(dat,1),1) dat];
            res{i} = dat;
        end

        res = cat(1,res{:});
        if isempty(res), continue; end
        OUTPUT_DIR = './Helpers/INRIAEval/data-USA/res/SpatialPooling+';
        if ~exist(OUTPUT_DIR,'dir'), mkdir(OUTPUT_DIR); end
        if ~exist(sprintf('%s/set%02d',OUTPUT_DIR,sid),'dir'), mkdir(sprintf('%s/set%02d',OUTPUT_DIR,sid)); end
        filename=sprintf('%s/set%02d/V%03d.txt', OUTPUT_DIR, sid, vid);
        dlmwrite(filename,res);

    end
end

fprintf('Plotting ROC curves ...\n');
dbEval;


function res = demo1(TEST_IMAGE_0, TEST_IMAGE_1)

MODEL_SIZE     = [50 20.5];
IMAGE_SIZE     = [480 640];
NUM_OCTAVE     = 8;
MODEL_FILENAME = 'model.mat';
STRIDE         = 4;
BING_THRESH    = -0.032;
PED_THRESH     = -0.5;


%
% Load BING and pedestrain detector models
%
if ~exist(MODEL_FILENAME, 'file'), return;
else  model = load(MODEL_FILENAME); ped_model=model.ped_model; bing_model=model.bing_model; end

%
% Compute optical flow between two consecutive images
%
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
t=toc; %fprintf('Extracting optical flow took: %.2f secs\n', t);
flow = cat(3,vx,vy);
flow=min(flowThreshold, flow); flow=max(-flowThreshold,flow);
flow=single(flow./flowThreshold); % flow image (single)
I   = im2single(im0);  % test image (single)
Iuint8 = im0;          % test image (uint8)


% Pre-compute BING masks at different scales
tic,
bing = evalBINGMex(Iuint8,bing_model); bing = bing(24:-1:1);
t=toc; %fprintf('Applying BING took: %.2f secs\n', t);


% get scales at which to compute features and list of real/approx scales
[scales,scaleshw]=getScales(NUM_OCTAVE,0,MODEL_SIZE,4,IMAGE_SIZE);
nScales=length(scales);



bbs = cell(nScales,1);
tic,
for i=1:nScales
    if i>length(bing), continue; end
    sc=scales(i); sc1=round(IMAGE_SIZE*sc/4); sc2=sc1*4;

    if size(I,1) ~= sc2(1) && size(I,2) ~= sc2(2)
        I1=imResampleMex(I,sc2(1),sc2(2),1); flow1=imResampleMex(flow,sc2(1),sc2(2),1);
    else
        I1=I; flow1=flow;
    end

    mask = zeros(sc1,'single');
    [h1,w1]=size(bing{i});
    if h1>sc1(1),h1=sc1(1); end, if w1>sc1(2),w1=sc1(2); end
    mask(1:h1,1:w1)=bing{i}(1:h1,1:w1);

    bb=detectPedMex(I1,flow1,mask,ped_model,STRIDE,PED_THRESH,BING_THRESH);

    if ~isempty(bb),
        bb(:,1) = (bb(:,1))./scaleshw(i,2);
        bb(:,2) = (bb(:,2))./scaleshw(i,1);
        bb(:,3:4) = bb(:,3:4)./sc;
        bbs{i}=bb;
    end
end
t=toc;
fprintf('Applying pedestrian detector took: %.2f secs\n', t);

bbs=cat(1,bbs{:});
bbs=bbNms(bbs,'type','maxg','overlap',0.65,'ovrDnm','min');
res = bbs;


