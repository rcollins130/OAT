
function [vid_tracks, vid_cdata, vid_times] = process_video(record, video_process, mapping)
%% Load Video
video_fullpath = strcat(...
    fullfile(...
        video_process.video_basepath, ...
        record...
    ),...
    video_process.extension ...
);

[vid_cdata, vid_times, ~] = load_video( ...
    video_fullpath, ...
    video_process.time_interval, ...
    video_process.crop_limits,...
    video_process.spatial_downsample, ...
    video_process.frame_downsample, ...
    video_process.load_grayscale...
);

%% TODO: Validate Frames
% appears sometimes frame may be corrupted in import / xfer. Use this
% to scrub those frames.

%% TODO: Perform exposure correction
% exposure changing througout some videos 

%% Binarize Video
% calculate background
vid_background = video_compute_background(vid_cdata, 4, video_process);

% get background-removed image
vid_nbg = video_subtract_background_and_normalize(vid_cdata, vid_background, video_process);

% binarize background-removed image, clear vid_nbg to save memory
vid_bin = video_binarize(vid_nbg, video_process);
clear vid_nbg

%% Identify ROIs
[regions, max_region_area] = video_identify_regions(vid_bin, video_process);
[regions, ~] = video_filter_regions(regions, max_region_area, video_process);

%% Form Tracks
[vid_tracks] = video_form_tracks(regions, vid_times, video_process);
[vid_tracks] = video_filter_tracks(vid_tracks, video_process);

%% Consolidate Tracks
[vid_tracks] = video_consolidate_tracks(vid_tracks, video_process);

%% Localize Tracks

%% Clean Up Struct for Export(?)

end


%% TODO and notes on next steps
% moving background - use a different background image for different frames
% downsample - reducing resolution will cut out high-frequency signals
% color binarize - binarize each color separately
% sum binarize - 

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

% Location & Scaling
% - create lookup table of key points visible in each video 
% - for each view angle, mark pixel points of the images 
% - compute rough angular displacement mapping
%