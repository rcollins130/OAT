function video_process = video_params(record)
%VIDEO_PARAMS Summary of this function goes here
%   Detailed explanation goes here

% define defaults
video_process.video_basepath = 'data/movie/';
video_process.extension = '.mp4';
video_process.time_interval = [];
video_process.crop_limits = [];
video_process.spatial_downsample = 1;
video_process.frame_downsample = 1;
video_process.load_grayscale = 0;
video_process.time_offset = seconds(0);

video_process.background_method = 'median';
video_process.normalization_method = 'all';
video_process.normalize_abs = 1;
video_process.binarize_method = 'percolor'; % need additional contrast to filter out moving clouds! add controls for binarization
video_process.binarize_percolor_mask = 'all';
video_process.binarize_percolor_dilate_r = 3;
video_process.binarize_percolor_open_r = 1;
video_process.binarize_percolor_holefill_r = 5;
video_process.binarize_percolor_obin_thold = 0.1;
% scale above based on size/length of frame

video_process.filter_regions_by_area = 0;
video_process.filter_regions_area_scale = 0.1;
video_process.region_overlap_method = 'bounding_box_overlap';
video_process.track_filter_length = 30;

video_process.consolidation_method = '';
video_process.manual_consolidation = {[1,2]};

% record-specific parmameters
if record=="20230317_145402"
    video_process.time_offset = duration(1,5,17); 
    video_process.time_interval = [8,18];
    video_process.binarize_percolor_obin_thold = 0.25;

elseif record == "20230321_162848"
    video_process.time_interval = [25, 50];
    video_process.binarize_percolor_obin_thold = 0.1;

elseif record == "20230317_190613"
    video_process.time_interval = [8, 18];
    video_process.crop_limits = [40, 1400; 325, 950];
    video_process.binarize_percolor_obin_thold = 0.1;

elseif record == "20230322_152347"
    video_process.time_interval = [0,22];
    video_process.binarize_percolor_obin_thold = 0.25;

else
    warning("No custom video parameters for %s, using defaults", record)
end


end

