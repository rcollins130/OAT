
% outline for processing videos

%% Load parameters
par.video_fname = 'data/movie/20230317_145402.mp4';


%% Location & Scaling
% - create lookup table of key points visible in each video 
% - for each view angle, mark pixel points of the images 
% - compute rough angular displacement mapping

%% Load Video
ts = get_mp4_creation_time(par.video_fname);

[vid_cdata, t, vidObj] = load_video( ...
    par.video_fname, ...
    [1,20], ...
    [],...%[200, 800; 500, 950], ...
    2, ...
    1 ...
    );

frame_time = ts+t;

%% Validate Frames
% appears sometimes frame may be corrupted in import / xfer. Use this
% to scrub those frames.

%% Identify Frame ROIs

% compute background

% subtract background & normalize

% moving background - use a different background image for different frames
% downsample - reducing resolution will cut out high-frequency signals
% color binarize - binarize each color separately
% sum binarize - 


%% Filter Individual ROIs
% size filtering


%% Form ROI Tracks


%% Filter Tracks
% speed filter


%% Identify Aircraft Tracks
