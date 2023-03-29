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
video_process.track_filter_method = 'longest';
video_process.track_filter_frame_length = 30;
video_process.track_filter_manual_idxs = [];

video_process.consolidation_method = '';
video_process.manual_consolidation = {};

% record-specific parmameters
if record=="20230317_145402"
    video_process.time_offset = -duration(1,5,13); 
    video_process.time_interval = [8,18];
    video_process.binarize_percolor_obin_thold = 0.25;

    video_process.track_filter_method = 'manual';
    video_process.track_filter_manual_idxs = [14];

    video_process.consolidation_method = '';

elseif record == "20230321_162848"
    video_process.frame_downsample = 2;

    video_process.time_interval = [26, 45];
    video_process.binarize_percolor_obin_thold = 0.1;

    video_process.track_filter_method = 'manual';
    video_process.track_filter_manual_idxs = [1];

elseif record == "20230321_194339"
    video_process.frame_downsample = 2;

    video_process.time_interval = [10, 29];
    video_process.binarize_percolor_obin_thold = 0.25;
    video_process.binarize_percolor_open_r = 0;

    video_process.track_filter_method = 'longest';

elseif record == "20230321_194950"
    video_process.frame_downsample = 2;
    video_process.time_interval = [1, 15];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.binarize_percolor_open_r = 0;
    video_process.track_filter_method = 'longest';

elseif record == "20230321_195551"
    video_process.frame_downsample = 2;
    video_process.time_interval = [5, 22];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.binarize_percolor_open_r = 0;
    video_process.track_filter_method = 'longest';

elseif record == "20230321_200127"
    video_process.frame_downsample = 2;
    video_process.time_interval = [10, 27];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.binarize_percolor_open_r = 0;
    video_process.track_filter_method = 'longest';

elseif record == "20230321_200549"
    video_process.frame_downsample = 2;
    video_process.time_interval = [23, 47];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_142550"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [6, 15];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_150057"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [15, 36];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_151255"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [0, 19];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_151422"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [17, 27];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_152037"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [8, 25];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_152805"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [18, 29];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_153053"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [7, 20];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';
    
elseif record == "20230322_153437"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [12, 27];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_153924"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [4, 25];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_154324"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [8, 31];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_154557"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [8, 25];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_154747"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [12, 29];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_155935"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [8, 28];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';


elseif record == "20230322_152347"
    video_process.time_offset = -duration(8,0,6); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [0, 22];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';


elseif record == "20230322_155108"
    video_process.time_offset = -duration(8,0,0); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [11, 28];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';
    
elseif record == "20230322_155502"
    video_process.time_offset = -duration(8,0,0); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [11, 21];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230322_162225"
    video_process.time_offset = -duration(8,0,0); 
    video_process.frame_downsample = 2;
    video_process.time_interval = [10, 26];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';



elseif record == "20230320_203920"
    video_process.frame_downsample = 1 ;
    video_process.time_interval = [22, 27];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230320_230902"
    video_process.frame_downsample = 1 ;
    video_process.time_interval = [10, 41];
    video_process.binarize_percolor_obin_thold = 0.1;
    video_process.track_filter_method = 'longest';

elseif record == "20230317_190613"
    video_process.time_interval = [8, 18];
    video_process.crop_limits = [40, 1400; 325, 950];
    video_process.binarize_percolor_obin_thold = 0.1;



else
    warning("No custom video parameters for %s, using defaults", record)
end


end

