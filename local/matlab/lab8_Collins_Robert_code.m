%%
% ME354 LAB 8
% DROP TRACK AND CORRELATION
% ROBERT COLLINS
% 02/22/2023

%% Setup
disp("BEGIN lab8_Collins_Robert_code.m")
clear;
 
%% Analysis Parameters
param_set = 1;
fprintf("Initialzing with Parameter Set [%d]\n", param_set)
[...
    params_input, ...
    params_preprocess, ...
    params_detectors, ...
    params_interface, ...
    params_output] = lab8_parameters(param_set);

% test plot indicies
ntp_r = length(params_preprocess.test_plot_frames);
ntp_c = 4;

%% Load Data
% 
fprintf("Loading %s ...", params_input.path_input_video);
% Read Frames within interval
%   https://www.mathworks.com/help/matlab/import_export/read-video-files.html#ReadVideoFiles28781487Example-2
vidObj = VideoReader(params_input.path_input_video);
vidObj.CurrentTime = params_input.time_interval(1);

% Initialize 3D Array (will be filled into 4D array)
if params_input.crop_input
    input_h = ceil(1/params_input.spatial_downsample * ...
        (params_input.crop_limits(2,2)-params_input.crop_limits(2,1)));
    input_w = ceil(1/params_input.spatial_downsample * ...
        (params_input.crop_limits(1,2)-params_input.crop_limits(1,1)));
else
    input_h = vidObj.Height;
    input_w = vidObj.Width;
end

if params_input.load_greyscale
    input_d = 1;
else
    input_d = 3;
end

vid_cdata = zeros(input_h, input_w, input_d, 'double');
vid_t = [];

% Read Each Frame Within Interval
ii_full=1;
ii_out=1;
while (vidObj.CurrentTime <= params_input.time_interval(2) && ...
        vidObj.CurrentTime < vidObj.Duration)
    % Get frame time read frame
    t = vidObj.CurrentTime;
    F = readFrame(vidObj);
    
    % Skip if not in frame_downsample
    if mod(ii_full, params_input.frame_downsample) == 0
        % spatially crop raw image (uint8)
        if params_input.crop_input
            F = F(...
            params_input.crop_limits(2,1):params_input.crop_limits(2,2)-1, ...
            params_input.crop_limits(1,1):params_input.crop_limits(1,2)-1, ...
            :);
        end
        % downsample cropped image
        F = F( ...
        1:params_input.spatial_downsample:end, ...
        1:params_input.spatial_downsample:end, ...
        :);
    
        % Convert to double, output to 4D array
        if params_input.load_greyscale
            F = rgb2gray(F);
        end
        vid_cdata(:,:,:,ii_out) = im2double(F);
        vid_t(ii_out) = t;

        ii_out = ii_out+1;
    end 
    % advance counter
    ii_full = ii_full+1;
end

% Adjust framerate, if required
if vidObj.FrameRate ~= params_input.fps
    vid_t = vid_t * (vidObj.FrameRate / params_input.fps);
end

if params_preprocess.test_plots
    figure(1)
    for ii=1:ntp_r
        ii_frame=params_preprocess.test_plot_frames(ii);
        subplot(ntp_r, ntp_c, 1+ntp_c*(ii-1))
        imshow(vid_cdata(:,:,:,ii_frame))
        title(sprintf("Raw Frame %d",ii_frame))
    end
end

disp("DONE")
% Report Loaded Data
fprintf("\t Loaded %s from %0.2fs to %0.2fs\n", ...
    params_input.path_input_video, ...
    min(vid_t), max(vid_t))
if params_input.crop_input
    fprintf("\t Crop within x:(%d, %d), y:(%d, %d)\n", ...
    params_input.crop_limits(1,:), ...
    params_input.crop_limits(2,:))
end
whos vid_data

if params_input.save_vid2mat
    fprintf("Saving video to mat...")
    save('Output/vid_cdata', 'vid_cdata','vid_t','-v7.3')
    disp("DONE")
end


%% Calculate Image Background
% Obtain the temporal array median for each color/pixel. 
%   Matlab function: median. 
%   (Hint: this step can be done in a single line using the %dim  argument of 
%    this function.) This yields the background image. (Note your background 
%    image will remain a color image composed for R, G, and B arrays.)
% Subtract the single temporal median image from the 4D array. This 
%   subtracts background from the series.

fprintf("Calculating background image with '%s'...", ...
    params_preprocess.background_method)

% Calculate background image by dictated method
if strcmp(params_preprocess.background_method, 'median')
    % 'median' - Median of each color channel in time
    vid_background = median(vid_cdata,4);
elseif strcmp(params_preprocess.background_method, 'imopen')
    % 'imopen' - morphological opening, merged in time
    % initialize background data for each color chan
    vid_background = zeros(size(vid_cdata,[1,2,3]));
    % grab x-y size of strel cuboid
    strel_size = params_preprocess.background_imopen_strelsize;
    % loop thru each channel
    for cidx=1:size(vid_cdata,3)
        % open video using cuboid strel spanning time axis
        vid_open = imopen( ...
            squeeze(vid_cdata(:,:,cidx,:)), ...
            strel('cuboid',[strel_size, size(vid_cdata,4)]) ...
            );
        % save to background (note all vid_open frames are identical)
        vid_background(:,:,cidx) = vid_open(:,:,1);
    end
else
    disp("ERROR")
    error("Unknown background_method %s, exiting\n", ...
        params_preprocess.background_method)
end

if params_preprocess.test_plots
    figure(1)
    for ii=1:ntp_r
        ii_frame=params_preprocess.test_plot_frames(ii);
        subplot(ntp_r, ntp_c, 2+ntp_c*(ii-1))
        imshow(vid_background(:,:,:))
        title(sprintf("Background"))
    end
end

disp("DONE")

%% Subtract Background
% Subtract the single temporal median image from the 4D array. This 
% subtracts background from the series.
fprintf("Subtracting background image with '%s' normalization...", ...
    params_preprocess.normalize_method)

% Subtract 3D background from 4D video
vid_data_nbg = vid_cdata - vid_background;

if params_preprocess.test_plots
    figure(1)
    for ii=1:ntp_r
        ii_frame=params_preprocess.test_plot_frames(ii);
        subplot(ntp_r, ntp_c, 3+ntp_c*(ii-1))
        imshow(vid_data_nbg(:,:,:,ii_frame))
        title(sprintf("NBg %d",ii_frame))
    end
end

if strcmp(params_preprocess.normalize_method, 'all')
    % Normalize entire 4D video to bring back in [0,1] range
    vid_data_nbgn = vid_data_nbg - min(vid_data_nbg,[],'all');
    vid_data_nbgn = vid_data_nbgn ./ max(vid_data_nbgn, [], 'all');
elseif strcmp(params_preprocess.normalize_method, 'frame')
    vid_data_nbgn = vid_data_nbgn - min(vid_data_nbgn, [], [1,2,3]);
    vid_data_nbgn = vid_data_nbgn ./ max(vid_data_nbgn, [], [1,2,3]);
elseif strcmp(params_preprocess.normalize_method, 'color')
    disp("NOT IMPLEMENTED")
    return
elseif strcmp(params_preprocess.normalize_method, 'imadjust')
    vid_data_nbgn = vid_data_nbg;
    for ii_frame=1:size(vid_data_nbgn, 4)

        if strcmp(params_preprocess.normalize_imadjust_limtype, 'fixed')
            in_lims = params_preprocess.normalize_imadjust_fixedlim;
        elseif strcmp(params_preprocess.normalize_imadjust_limtype, 'stretch')
            in_lims = stretchlim( ...
                vid_data_nbgn(:,:,:,ii_frame), ...
                params_preprocess.normalize_imadjust_stretchlim ...
                );
        else
            in_lims = [];
        end

        vid_data_nbgn(:,:,:,ii_frame) = imadjust( ...
            vid_data_nbgn(:,:,:,ii_frame), ...
            in_lims ...
            );
    end
elseif strcmp(params_preprocess.normalize_method, 'imadjustn')
    if strcmp(params_preprocess.normalize_imadjust_limtype, 'fixed')
        in_lims = params_preprocess.normalize_imadjust_fixedlim;
    elseif strcmp(params_preprocess.normalize_imadjust_limtype, 'stretch')
        %warning('cannot use stretch lims with imadjustn, reverting to default')
        %in_lims = [];
        in_lims = stretchlim( ...
                vid_data_nbg(:), ...
                params_preprocess.normalize_imadjust_stretchlim ...
                );
    else
        in_lims = [];
    end
    vid_data_nbgn = imadjustn( ...
        vid_data_nbg, ...
        in_lims ...
        );
elseif strcmp(params_preprocess.normalize_method, 'none')
    % no additional normalization - may cause issuse in output movie
    vid_data_nbgn = vid_data_nbg;
else
    disp("ERROR")
    fprintf("Unknown normalize_method %s, exiting\n", ...
        params_preprocess.normalize_method)
    return
end

if params_preprocess.test_plots
    figure(1)
    for ii=1:ntp_r
        ii_frame=params_preprocess.test_plot_frames(ii);
        subplot(ntp_r, ntp_c, 4+ntp_c*(ii-1))
        imshow(vid_data_nbgn(:,:,:,ii_frame))
        title(sprintf("NBg Normal %d",ii_frame))
    end
end

disp("DONE")

%% Cross-Correlation
% Manually place 2 “superpixel” detectors within the path of the droplets. 
% These should be within the breakup/droplet region and should be 
% sufficiently spaced apart for good sampling (See fig. 1).
%
% Compute the average intensity I(t) within each detector for each 
% timestep. 
%
% Compute time-delayed auto-covariances of I(t) vs time for each detector.
%
% Compute time-delayed cross-covariances of I(t) between detectors 1 and 2.
% 
if params_detectors.do_xcorr
fprintf("XCorr: Computing time-delayed covariances...")

d_intensity = zeros(size(vid_data_nbgn,4),2);
for ii_frame=1:size(vid_data_nbgn,4)
    for ii_detector=1:size(params_detectors.locations, 2)
        loc = params_detectors.locations(ii_detector,:);
        d_intensity(ii_frame, ii_detector) = mean( ...
            vid_data_nbgn( ...
                loc(2):loc(2)+params_detectors.size(2)-1, ...
                loc(1):loc(1)+params_detectors.size(1)-1, ...
                1,ii_frame ...
                ) ...
            ,'all');
    end
end

[d_xcovs, lags] = xcov(d_intensity);
tau = lags * 1/params_input.fps;
tau_trim = tau(:,ceil(length(lags)/2):end);
d_xcovs_trim = d_xcovs(ceil(length(lags)/2):end, :);
 
disp("DONE")
end
%% Cross-Correlation Analysis
% With some (estimate) knowledge of the length scale for the image 
% [i.e. mm/pixel] and the framerate of the video [frames/sec], 
% determine the time-averaged velocity V of the droplets using the 
% cross-covariance data.
% 
% Using the velocity V determined from last step and the auto-covariance 
% data, estimate the size of a droplet for each detector.
if params_detectors.do_xcorr
fprintf("XCorr: Performing Cross-Correlation Analysis...")

% Estimate droplet velocity
% time shift of cross-correlation peak
[~,I] = max(d_xcovs_trim(:,3));
t_shift = tau_trim(I);

% distance between detectors
x_shift = norm(diff(params_detectors.locations,1))/params_input.px_per_m;

v_droplet = x_shift/t_shift;

% Estimate droplet size
d_droplet = zeros(size(params_detectors.locations, 1));
autocorrs = d_xcovs_trim(:,[1 4]);
for ii_detector=1:size(d_droplet,1)
    % Find full width at half max of autocorrelation
    %   make vector of autocorr shifted by half max
    acorr_shifted = autocorrs(:,ii_detector) - max(autocorrs(:,ii_detector))/2;
    %   find index before zero crossing, interpolate to estimate value
    I = find(diff(sign(acorr_shifted)));
    fullw = 2*(tau_trim(I)+tau_trim(I+1))/2;
    %   compute residence time and droplet diameter
    t_residence = fullw*sqrt(2);
    d_droplet(ii_detector) = v_droplet*t_residence;
end

disp("DONE")
fprintf("\t Droplet Velocity: %0.3f m/s\n", v_droplet)
fprintf("\t Det1 Droplet Size: %0.3f mm\n", d_droplet(1)*1e3)
fprintf("\t Det2 Droplet Size: %0.3f mm\n", d_droplet(2)*1e3)
end

%% Interface Detection
% Perform interface detection with 
% imbinarize, imdilate, imfill, imerode, and imclearborder
% Note: 
% imbinarize will convert image intensities to 1 or 2. Choose a 
% threshold value that will distinguish droplet intensities from the rest 
% of the image. imdilate and imfill together will help "fill in” artifacts 
% “holes” in the image elements/droplets, resulting in contiguous regions. 
% imerode approximately undoes the artificial area growths caused by 
% imdilate. 
% imclearborder ignores regions overlapping with image border (although 
% these should not exist in your raw data).
if params_interface.do_it
fprintf("Interface Tracking: Detecting Interfaces...")

% define structuring element
se = strel( ...
        params_interface.dilate_strel, ...
        params_interface.dilate_strel_r ...
        );

% crop background-removed data
vid_data_nbgn_crop = vid_data_nbgn( ...
    params_interface.comp_range(2,1):params_interface.comp_range(2,2)-1, ...
    params_interface.comp_range(1,1):params_interface.comp_range(1,2)-1, ...
    :, ...
    :);

% initialize binarized data
vid_binary = zeros(size(vid_data_nbgn_crop,[1,2,4]));

% binarize image
for ii_frame = 1:size(vid_data_nbgn_crop, 4)
    frame_nbgn = vid_data_nbgn_crop(:,:,:,ii_frame);
    frame_bin = imbinarize(frame_nbgn, params_interface.binarize_thold);
    
    frame_dia = imdilate(frame_bin,se);
    frame_fill = imfill(frame_dia,"holes");
    frame_err = imerode(frame_fill,se);
    frame_cb = imclearborder(frame_err);
    
%     subplot(1,6,1); imshow(frame_nbgn)
%     subplot(1,6,2); imshow(frame_bin)
%     subplot(1,6,3); imshow(frame_dia)
%     subplot(1,6,4); imshow(frame_fill)
%     subplot(1,6,5); imshow(frame_err)
%     subplot(1,6,6); imshow(frame_cb)
%         pause(0.01)

    vid_binary(:,:,ii_frame) = frame_cb;
end

disp("DONE")
end

%% Interface Analysis
% Note you can find droplet outlines, quantify droplet area statistics, 
% and plot centroids using bwconncomp, edge, regionprops.
% Note: 
% bwconncomp will find the number of connected (contiguous) elements. 
% The edge function provides you with the edges you will superpose on 
% the raw images and create a movie (see below). 
% regionprops will assign them numbers and help you extract their 
% centroid and area properties (although this is not needed here).
if params_interface.do_it
fprintf("Interface Tracking: Analyze Droplets...")

% vid_edges = zeros(size(vid_binary));
% droplet_stats = cell(size(vid_binary,3),1);
vid_edges = zeros(size(vid_cdata,[1,2,4]));
droplet_stats = cell(size(vid_cdata,4),1);

for ii_frame = 1:size(vid_binary, 3)
    CC = bwconncomp(vid_binary(:,:,ii_frame));
%     vid_edges(:,:,ii_frame) = edge(vid_binary(:,:,ii_frame));
%     droplet_stats{ii_frame} = regionprops(CC);
    sub_edges = edge(vid_binary(:,:,ii_frame));
    sub_stats = regionprops(CC);
    % adjust edges and stats to match full image
    vid_edges( ...
        params_interface.comp_range(2,1):params_interface.comp_range(2,2)-1, ...
        params_interface.comp_range(1,1):params_interface.comp_range(1,2)-1, ...
        ii_frame) = sub_edges;

    min_corn = [params_interface.comp_range(1,1), params_interface.comp_range(2,1)];
    
    for ii_drop=1:length(sub_stats)
    sub_stats(ii_drop).Centroid = sub_stats(ii_drop).Centroid + min_corn;
    sub_stats(ii_drop).BoundingBox = sub_stats(ii_drop).BoundingBox + [min_corn min_corn];
    end
    droplet_stats{ii_frame} = sub_stats;
end

disp("DONE")
end

%% Output Plots
if params_output.create_plots
fprintf("Creating Output Plots...")
close all
% Create output directory
if ~exist(params_output.output_dir, 'dir')
    mkdir(params_output.output_dir)
end

% Figure 1: A single image of the background subtracted jet with 
% each detector region from Step 1 overlaid
figure('Name','Figure 1','Position',[10,10,600,600]); clf; hold on;

im = imshow(vid_data_nbgn(:,:,:,params_output.fig1_frame));
title(sprintf("Background-Subtracted Frame at %0.4fs",vid_t(params_output.fig1_frame)))
for ii_detector=1:size(params_detectors.locations, 2)
    loc = params_detectors.locations(ii_detector,:);
    sz = params_detectors.size;
    rec = rectangle(im.Parent,'Position',[loc, sz],'EdgeColor','r','LineWidth',2);
end
hline = line(NaN, NaN,'LineWidth',1, 'Color','r');
legend(hline, 'Detector Region','Location','southwest')
saveas(gcf,fullfile(params_output.output_dir, 'fig1.png'))

% Figure 2: A selected frame from your original video with overlaid 
% droplet centroids and edges from Step 2
figure('Name','Figure 2','Position',[10,10,600,600]); clf; hold on;
% plot image with edges
plotframe = vid_cdata(:,:,:,params_output.fig2_frame);
if size(plotframe, 3)==1
    plotframe = cat(3, plotframe,plotframe,plotframe);
end
plotedges = vid_edges(:,:,params_output.fig2_frame);
cedges = cat(3, plotedges, zeros(size(plotedges)), zeros(size(plotedges)));
plotframe(cedges(:,:,1)~=0) = plotedges(cedges(:,:,1)~=0);
im = imshow(plotframe);

% plot centroids
hold on
for ii_droplet=1:length(droplet_stats{params_output.fig2_frame})
    cent = droplet_stats{params_output.fig2_frame}(ii_droplet).Centroid;
    p=plot(cent(1),cent(2), 'gx');
end
hline = line(NaN, NaN,'LineWidth',1, 'Color','r');

legend([hline,p], 'Droplet Boundary','Droplet Centroid','Location','southwest')

% plot scale bar
bar_width = 1e-3 * params_output.scale_bar_mm * params_input.px_per_m;
rectangle('Position',[10, 10, bar_width, bar_width/5],'FaceColor','w','EdgeColor','w')
text(10+bar_width/2,10+bar_width/5, ...
    sprintf("%dmm", params_output.scale_bar_mm), ...
    'Color','w','HorizontalAlignment','center', ...
    'VerticalAlignment','top')

title(sprintf("Raw Frame at t=%0.4fs",vid_t(params_output.fig2_frame)))
saveas(gcf,fullfile(params_output.output_dir, 'fig2.png'))

% Figure 3: Auto-covariance vs time for each detector region and 
% cross-covariance vs time from Part 1. Indicate in
% your plots the calculated value for drop size (using auto-covariance) 
% and velocity (using cross-covariance).
% Further, provide additional plots which focus on the main covariance 
% peaks.
figure('Name','Figure 3','Position',[10,10,600,600]); clf; hold on;
largelim = 2;
smalllim = 0.1;
subplot(2,3,1); hold on
title({"Auto-Covariance 11",sprintf("Drop Size %0.3f mm", d_droplet(1)*1e3)})
plot(tau, d_xcovs(:,1))
xlabel("\tau, s")
ylabel("C_{xx}")
xlim([0,largelim]);

subplot(2,3,2); hold on
title({"Auto-Covariance 22",sprintf("Drop Size %0.3f mm", d_droplet(2)*1e3)})
plot(tau, d_xcovs(:,4))
xlabel("\tau, s")
ylabel("C_{xx}")
xlim([0,largelim]);

subplot(2,3,3); hold on
title({"Cross-Covariance 12",sprintf("Velocity %0.3f mm/s", v_droplet*1e3)})
plot(tau, d_xcovs(:,3))
xlabel("\tau, s")
ylabel("C_{xy}")
xlim([0,largelim]);

subplot(2,3,4); hold on
plot(tau, d_xcovs(:,1))
xlabel("\tau, s")
ylabel("C_{xx}")
xlim([0,smalllim]);

subplot(2,3,5); hold on
plot(tau, d_xcovs(:,4))
xlabel("\tau, s")
ylabel("C_{xx}")
xlim([0,smalllim]);

subplot(2,3,6); hold on
plot(tau, d_xcovs(:,3))
xlabel("\tau, s")
ylabel("C_{xy}")
xlim([0,smalllim]);

str="Note: Could not record video at a high enough fps to resolve droplet size differences.";
annotation(gcf,"textbox",[0.18,0.0125,0.66,0.0375], ...
    'String',str,'FitBoxToText','on');

saveas(gcf,fullfile(params_output.output_dir, 'fig3.png'))
disp("DONE")
end
%% Output Movie
% .mp4 movie: your original video with overlaid droplet centroids and edges
if params_output.create_video
fprintf("Creating Output Video... ")

vidWriter = VideoWriter( ...
    fullfile(params_output.output_dir, 'video.mp4'), ...
    params_output.video_format);
open(vidWriter);

figure('Name','Figure 4','Position',[10,10,600,600]); clf; hold on;
% plot image with edges
for ii_frame=1:size(vid_cdata,4)
    plotframe = vid_cdata(:,:,:,ii_frame);
    if size(plotframe, 3)==1
        plotframe = cat(3, plotframe,plotframe,plotframe);
    end
    plotedges = vid_edges(:,:,ii_frame);
    cedges = cat(3, plotedges, zeros(size(plotedges)), zeros(size(plotedges)));
    plotframe(cedges(:,:,1)~=0) = plotedges(cedges(:,:,1)~=0);
    im = imshow(plotframe);
    
    % plot centroids
    hold on
    for ii_droplet=1:length(droplet_stats{ii_frame})
        cent = droplet_stats{ii_frame}(ii_droplet).Centroid;
        p=plot(cent(1),cent(2), 'gx');
    end
    
    % scale bar
    bar_width = 1e-3 * params_output.scale_bar_mm * params_input.px_per_m;
    rectangle('Position',[10, 10, bar_width, bar_width/5],'FaceColor','w','EdgeColor','w')
    text(10+bar_width/2,10+bar_width/5, ...
    sprintf("%dmm", params_output.scale_bar_mm), ...
    'Color','w','HorizontalAlignment','center', ...
    'VerticalAlignment','top')

    F = getframe(gcf);
    writeVideo(vidWriter, F)
    hold off
end

close(vidWriter);
disp("DONE")
end

%% test block
if 0
figure(); hold on;
im = imshow(vid_data_nbgn(:,:,:,1));
tit = title(sprintf("%0.5fs",vid_t(1)));
for ii_detector=1:size(params_detectors.locations, 2)
    loc = params_detectors.locations(ii_detector,:);
    sz = params_detectors.size;
    rec = rectangle(im.Parent,'Position',[loc, sz],'EdgeColor','r','LineWidth',1);
end

for ii=1:size(vid_data_nbgn,4)
    tit.String = sprintf("%0.5fs",vid_t(ii));
    im.CData = vid_data_nbgn(:,:,:,ii);
    drawnow()
    pause(0.01)
end
end

%% test block
if 0
figure(); hold on;
im = imshow(vid_edges(:,:,1));
tit = title(sprintf("%0.5fs",vid_t(1)));

for ii=1:size(vid_data_nbgn,4)
    tit.String = sprintf("%0.5fs",vid_t(ii));
    im.CData = vid_edges(:,:,ii);
    drawnow()
    pause(0.01)
end
end