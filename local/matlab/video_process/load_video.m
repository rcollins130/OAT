


function [vid_cdata, vid_t, vidObj] = load_video(filepath, time_interval, crop_limits, spatial_downsample, frame_downsample, load_grayscale)
%%
%
% filename 
% time_interval 
% crop_limits : [x_min x_max; y_min y_max]
% spatial_downsample
% frame_downsample 
% load_grayscale 

arguments
    filepath (1,1) string
    time_interval double = []
    crop_limits double = []
    spatial_downsample (1,1) double = 1
    frame_downsample (1,1) double = 1
    load_grayscale (1,1) double = 0
end

vidObj = VideoReader(filepath);

if isempty(time_interval)
    time_interval = [0, vidObj.Duration];
end
vidObj.CurrentTime = time_interval(1);

if isempty(crop_limits)
    crop_limits = [1, vidObj.Width; 1, vidObj.Height];
end
% Initialize 3D Array (will be filled into 4D array)
input_h = ceil(1/spatial_downsample*(crop_limits(2,2)-crop_limits(2,1)));
input_w = ceil(1/spatial_downsample*(crop_limits(1,2)-crop_limits(1,1)));

if load_grayscale
    input_d = 1;
else
    input_d = 3;
end

% initialize array with extra length
est_length = ceil((time_interval(2)-time_interval(1)) * vidObj.FrameRate) + 100;
vid_cdata = zeros(input_h, input_w, input_d, est_length,'single');
vid_t = seconds(zeros(est_length,1));

% Read Each Frame Within Interval
ii_full=1;
ii_out=1;
while (vidObj.CurrentTime < time_interval(2) && ...
        vidObj.CurrentTime < vidObj.Duration)
    % Get frame time read frame
    t = seconds(vidObj.CurrentTime);
    F = readFrame(vidObj);
    
    % Skip if not in frame_downsample
    if mod(ii_full, frame_downsample) == 0
        % spatially crop raw image (uint8) with downsample
        F = F(...
        crop_limits(2,1):spatial_downsample:crop_limits(2,2)-1, ...
        crop_limits(1,1):spatial_downsample:crop_limits(1,2)-1, ...
        :);

        % Convert to double, output to 4D array
        if load_grayscale
            F = rgb2gray(F);
        end
        vid_cdata(:,:,:,ii_out) = im2double(F);
        vid_t(ii_out,:) = t;

        ii_out = ii_out+1;
    end 
    % advance counter
    ii_full = ii_full+1;
end

vid_cdata = vid_cdata(:,:,:,1:ii_out-1);
vid_t = vid_t(1:ii_out-1);

% Shift video time using creation time from mp4 file
ts = get_mp4_creation_time(filepath);
vid_t = vid_t+ts;

end

function ts = get_mp4_creation_time(fname)
    cmd = sprintf("ffprobe -v quiet %s -print_format csv -show_entries stream=index,codec_type:stream_tags=creation_time:format_tags=creation_time",fname);
    [~,raw] = system(cmd,"PATH","/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin");
    lines = split(raw,[newline,","]);
    ts = datetime(lines{4},'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z');
end