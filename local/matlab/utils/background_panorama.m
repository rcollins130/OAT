
%% Script for merging camera views into single panorama

%% setup
clear
source_dir = 'data/movie';

%% get best background images
vp.background_method = 'median';

% get movies in source dir
file_listing = dir(fullfile(source_dir, '*.mp4'));
n_vids = size(file_listing, 1);

all_bgs = cell(n_vids, 1);

gray_bbgs = cell(n_vids, 1);
idx_bbgs = zeros(n_vids,1);
ii_bbg = 0;

rec2bbg = zeros(n_vids,2);

for ii_f=1:n_vids
    record = replace(file_listing(ii_f).name, ".mp4","");
    fprintf("Processing %s (%d/%d)\n", record, ii_f, n_vids);

    vid_cdata = load_video( ...
        fullfile(file_listing(ii_f).folder, file_listing(ii_f).name), ...
        [0,1] ...
        );
    
    this_bg = video_compute_background(vid_cdata,4,vp);
    all_bgs{ii_f} = this_bg;
    this_bg = im2gray(this_bg);

    this_sims = zeros(ii_bbg,1);
    for jj_bbg = 1:ii_bbg
        this_sims(jj_bbg) = ssim(this_bg, gray_bbgs{jj_bbg});
    end
    disp(this_sims)
    [M,I] = max(this_sims);
    if M>0.85
        rec2bbg(ii_f,:) = [I,M];
    else
        ii_bbg = ii_bbg + 1;
        gray_bbgs{ii_bbg} = this_bg;
        idx_bbgs(ii_bbg) = ii_f;
        rec2bbg(ii_f,:) = [ii_bbg,1];
    end

end

idx_bbgs = idx_bbgs(1:ii_bbg);

%% Display backgrounds, manually arrange into sequence
montage(all_bgs(idx_bbgs));

sequence = [15,14,13,8,9,10,11,12,2,1,3,4,5,6];

%% Do transform



%% test transforms
i1 = im2gray(all_bgs{idx_bbgs(15)});
i2 = im2gray(all_bgs{idx_bbgs(14)});

i1=double(i1);
i2=double(i2);

pts1 = detectSURFFeatures(i1);
[f1, pts1] = extractFeatures(i1, pts1);
pts2 = detectSURFFeatures(i2);
[f2, pts2] = extractFeatures(i2, pts2);

indexPairs = matchFeatures(f1, f2, 'Unique', true);
mp1 = pts1(indexPairs(:,1),:);
mp2 = pts2(indexPairs(:,2),:);
tform = estgeotform2d(mp1, mp2,'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

[xlim, ylim] = outputLimits(tform, [1 size(i1,2)], [1 size(i1,1)]);

maxImageSize = size(i1);

% Find the minimum and maximum output limits. 
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 1], 'like', I);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

warpedImage = imwarp(i1,tform,'OutputView',panoramaView);
mask = imwarp(true(size(i1,1),size(i1,2)),tform,'OutputView',panoramaView);

panorama = step(blender, panorama, warpedImage, mask);
