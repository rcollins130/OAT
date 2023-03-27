
% outline for processing videos

%% Load parameters
par.video_import.video_basepath = 'data/movie/';

par.video_import.record = '20230317_145402';
par.video_import.time_interval = [8,18];
par.video_process.binarize_percolor_obin_thold = 0.25;

% par.video_import.record = '20230321_162848.mp4';
% par.video_import.time_interval = [25, 50];
% par.video_process.binarize_percolor_obin_thold = 0.1;

% par.video_import.record = '20230317_190613.mp4';
% par.video_import.time_interval = [8, 18];
% par.video_import.crop_limits = [40, 1400; 325, 950];
% par.video_process.binarize_percolor_obin_thold = 0.1;

% par.video_import.record = '20230322_152347.mp4';
% par.video_import.time_interval = [0,22];
% par.video_process.binarize_percolor_obin_thold = 0.25;

par.video_import.extension = '.mp4';
par.video_import.crop_limits = [];
par.video_import.spatial_downsample = 1;
par.video_import.frame_downsample = 1;
par.video_import.load_grayscale = 0;

par.video_process.background_method = 'median';
par.video_process.normalization_method = 'all';
par.video_process.normalize_abs = 1;
par.video_process.binarize_method = 'percolor'; % need additional contrast to filter out moving clouds! add controls for binarization
par.video_process.binarize_percolor_mask = 'all';
par.video_process.binarize_percolor_dilate_r = 3;
par.video_process.binarize_percolor_open_r = 1;
par.video_process.binarize_percolor_holefill_r = 5;
% par.video_process.binarize_percolor_obin_thold = 0.1;
% scale above based on size/length of frame

par.video_tracking.filter_regions_by_area = 0;
par.video_tracking.filter_regions_area_scale = 0.1;
par.video_tracking.region_overlap_method = 'bounding_box_overlap';
par.video_tracking.track_filter_length = 30;

%% Location & Scaling
% - create lookup table of key points visible in each video 
% - for each view angle, mark pixel points of the images 
% - compute rough angular displacement mapping


%% Load Video
video_fullpath = strcat(...
    fullfile(par.video_import.video_basepath, ...
    par.video_import.record),...
    par.video_import.extension);

[vid_cdata, vid_times, ~] = load_video( ...
    video_fullpath, ...
    par.video_import.time_interval, ...
    par.video_import.crop_limits,...
    par.video_import.spatial_downsample, ...
    par.video_import.frame_downsample, ...
    par.video_import.load_grayscale...
);

%% Validate Frames
% appears sometimes frame may be corrupted in import / xfer. Use this
% to scrub those frames.

%% Perform exposure correction
% exposure changing througout some videos 

%% Identify Frame ROIs

vid_background = video_compute_background(vid_cdata, 4, par.video_process);

vid_nbg = video_subtract_background_and_normalize(vid_cdata, vid_background, par.video_process);

vid_bin = video_binarize(vid_nbg, par.video_process);
clear vid_nbg

[regions, max_region_area] = video_identify_regions(vid_bin, par.video_process);

[regions, max_region_area] = video_filter_regions(regions, max_region_area, par.video_tracking);

[vid_tracks] = video_form_tracks(regions, vid_times, par.video_tracking);

[vid_tracks] = video_filter_tracks(vid_tracks, par.video_tracking);

% moving background - use a different background image for different frames
% downsample - reducing resolution will cut out high-frequency signals
% color binarize - binarize each color separately
% sum binarize - 

%% scratch plotting
plot_regions([], vid_cdata, vid_times, regions)
plot_track_formation([], vid_cdata, vid_times, vid_tracks)

figure(4); clf;
subplot(5,1,1); hold on; ylabel('BB Area');
subplot(5,1,2); hold on; ylabel('BB Width');
subplot(5,1,3); hold on; ylabel('BB Height');
subplot(5,1,4); hold on; ylabel('Centroid X');
subplot(5,1,5); hold on; ylabel('Centroid Y');
xlabel('Time')
for ii_t=1:size(vid_tracks,2)
    t = vid_tracks(ii_t).times;
    cent = vid_tracks(ii_t).centroids;
    bbs = vid_tracks(ii_t).bbs;
    subplot(5,1,1)
    plot(t, bbs(:,3).*bbs(:,4),'DisplayName',sprintf("%d",ii_t));
    subplot(5,1,2)
    plot(t, bbs(:,3),'DisplayName',sprintf("%d",ii_t));
    subplot(5,1,3)
    plot(t, bbs(:,4),'DisplayName',sprintf("%d",ii_t));
    subplot(5,1,4)
    plot(t, cent(:,1),'DisplayName',sprintf("%d",ii_t));
    subplot(5,1,5)
    plot(t, cent(:,2),'DisplayName',sprintf("%d",ii_t));
end

subplot(5,1,1)
legend()

%% scratch location work for 20230317_145402
home_tree= 44.75;
home_p2 = 59.91;
home_p3 = 49.16;
p3_x = 516;
p2_x= 1360;
tree_x=199;

deg_per_x = (home_p3 - home_p2)/(p3_x-p2_x);

vt_x = vid_tracks(1).centroids(:,1);
vt_az = -(vt_x-tree_x)*deg_per_x + home_tree;
% note- timing is still very off!!

% current location plan:
%   - get list of known points (above), w/ bearing and x-value
%       - NOTE! should try to get elevation data too, somehow
%       - might be able to use an estimate of known roof / pole heights?
%   - convert plane x-pos to azimuth using above data
%       - NOTE! should look into dewarping image?
%   - convert ads-b locations to azimuth rel2 home
%   - stack on top- 
%       - NOTE! timing is critical - use plane passing tree to correlate?
% 
% from presentation:
% do velocity measurements based on plane length - 
% look at known length, and "plane lengths per frame" -> aircraft velocity
%
% Try if/and filters for birds: direction, size, periodicity of bb
%

%% Filter Individual ROIs
% size filtering


%% Form ROI Tracks


%% Filter Tracks
% speed filter


%% Identify Aircraft Tracks
