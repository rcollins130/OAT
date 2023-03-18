%%
% ME354 LAB 8
% DROP TRACK AND CORRELATION
% PARAMETER SETS
% ROBERT COLLINS
% 02/22/2023

function [ ...
    params_input, ...
    params_preprocess, ...
    params_detectors, ...
    params_interface, ...
    params_output...
    ] = lab8_parameters(param_set)

%% COMMON PARAMETERS
% Parameters overridden in realization-specific section left empty []

% Preprocessing
params_preprocess.test_plots = 1;
params_preprocess.test_plot_frames = [1,5];
params_preprocess.background_method = 'median';
params_preprocess.background_imopen_strelsize = [10,10];
params_preprocess.normalize_method = 'imadjust';
params_preprocess.normalize_imadjust_limtype = 'stretch';
params_preprocess.normalize_imadjust_fixedlim = [0.01, 0.1];
params_preprocess.normalize_imadjust_stretchlim = [0.95, 0.99];

% Input
params_input.path_input_video = "";
params_input.time_interval = []; % note- not accurate for fps
params_input.crop_input = 0;
params_input.crop_limits = [];
params_input.fps = [];
params_input.load_greyscale = 1;
params_input.px_per_m = []; 
params_input.spatial_downsample = 1;
params_input.frame_downsample = 1;
params_input.save_vid2mat = 0;

% Detectors
params_detectors.do_xcorr = 1;
params_detectors.size = [10, 10];
params_detectors.locations = [];

% Interface Tracking
params_interface.do_it = 1;
params_interface.comp_range = [];
params_interface.binarize_thold = 0.95;
params_interface.dilate_strel = 'disk';
params_interface.dilate_strel_r = 2;

% Output
params_output.create_plots = 1;
params_output.output_dir = [];
params_output.fig1_frame = 50;
params_output.fig2_frame = 10;
params_output.scale_bar_mm = 10;
params_output.create_video = 1;
params_output.video_format = 'MPEG-4';


%% REALIZATION-SPECIFIC PARAMETERS
if param_set == 1
%% PARAM SET 1
% scale vid
% params_input.path_input_video = "Media/JFCJ5436.MOV";
params_input.path_input_video = "Media/KKSU4102.MOV";
params_input.time_interval = [0.1, 20]; % note- not accurate for fps
params_input.crop_input = 1;
params_input.crop_limits = [150, 450; 
                            170, 850];
params_input.fps = 60;
params_input.px_per_m = 6800; 
params_input.spatial_downsample = 1;
params_input.frame_downsample = 1;
params_input.save_vid2mat = 0;


params_detectors.locations = [...
    170, 256;
    179, 378;
    ];

params_interface.comp_range = [
    100, 244;
    265, 507;
];

params_output.output_dir = "Output_Param1";

elseif param_set == 2
%% PARAM SET 2
params_input.path_input_video = "Media/2023-02-22 10-30-20 QZCW 1920x1080 240fps 2.mov";
params_input.time_interval = [0.1, 15]; % note- not accurate for fps
params_input.crop_input = 1;
params_input.crop_limits = [350, 717; 
                            224, 1158];
params_input.fps = 138;
params_input.px_per_m = 6700; 
params_input.spatial_downsample = 1;
params_input.frame_downsample = 1;
params_input.save_vid2mat = 0;

params_detectors.locations = [...
    170, 256;
    179, 378;
    ];

params_output.output_dir = "Output_Param2";

elseif param_set == 3
%% PARAM SET 3
params_input.path_input_video = "Media/IMG_0381.MOV";
params_input.time_interval = [0.1, 5]; % note- not accurate for fps
params_input.crop_input = 1;
params_input.crop_limits = [1, 1080; 
                            1, 1920];
params_input.fps = 60;
params_input.px_per_m = 11600;
params_input.spatial_downsample = 2;
params_input.frame_downsample = 1;
params_input.save_vid2mat = 0;

params_detectors.locations = [...
    339, 439;
    345, 580
    ];

params_interface.comp_range = [
    157, 492;
    336, 811;
];

params_preprocess.normalize_imadjust_stretchlim = [0.99, 0.999];

params_output.output_dir = "Output_Param3";

elseif param_set == 4
% params_input.path_input_video = "Media/JFCJ5436.MOV";
params_input.path_input_video = "Media/IMG_0391.MOV";
params_input.time_interval = [0.1, 20]; % note- not accurate for fps
params_input.crop_input = 1;
params_input.crop_limits = [125, 517; 
                            309, 949];
params_input.fps = 138;
params_input.px_per_m = (741-609)/2e-2; 
params_input.spatial_downsample = 1;
params_input.frame_downsample = 1;
params_input.save_vid2mat = 0;


params_detectors.locations = [...
    202, 317;
    207, 400;
    ];

params_interface.comp_range = [
    128, 305;
    208, 496;
];

params_output.output_dir = "Output_Param4";

elseif param_set == 5
% params_input.path_input_video = "Media/JFCJ5436.MOV";
params_input.path_input_video = "Media/XHWA0371.MOV";
params_input.time_interval = [0.1, 2]; % note- not accurate for fps
params_input.crop_input = 1;
params_input.crop_limits = [125, 700; 
                            275, 1200];
params_input.fps = 139;
params_input.px_per_m = (741-609)/2e-2; 
params_input.spatial_downsample = 1;
params_input.frame_downsample = 1;
params_input.save_vid2mat = 0;


params_detectors.locations = [...
    227, 480;
    229, 580;
    ];

params_interface.comp_range = [
    125, 345;
    554, 838;
];

params_preprocess.normalize_imadjust_stretchlim = [0.98, 0.995];

params_output.output_dir = "Output_Param5";

else
    error("Unknown param_set: %d", param_set)
end

end