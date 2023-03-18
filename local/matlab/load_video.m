


function [vid_cdata, vid_t, vidObj] = load_video(filename, time_interval, crop_limits, spatial_downsample, frame_downsample, load_grayscale)
%%
%
% filename 
% time_interval 
% crop_limits : [x_min x_max; y_min y_max]
% spatial_downsample
% frame_downsample 
% load_grayscale 

arguments
    filename (1,1) string
    time_interval double = []
    crop_limits double = []
    spatial_downsample (1,1) double = 1
    frame_downsample (1,1) double = 1
    load_grayscale (1,1) double = 0
end

if isempty(time_interval)
    time_interval = [0, 9e9];
end

vidObj = VideoReader(filename);
vidObj.CurrentTime = time_interval(1);
readFrame(vidObj);

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

vid_cdata = zeros(input_h, input_w, input_d, 'double');
vid_t = duration.empty;

% Read Each Frame Within Interval
ii_full=1;
ii_out=1;
while (vidObj.CurrentTime <= time_interval(2) && ...
        vidObj.CurrentTime < vidObj.Duration)
    % Get frame time read frame
    t = seconds(vidObj.CurrentTime);
    F = readFrame(vidObj);
    
    % Skip if not in frame_downsample
    if mod(ii_full, frame_downsample) == 0
        % spatially crop raw image (uint8)
        F = F(...
        crop_limits(2,1):crop_limits(2,2)-1, ...
        crop_limits(1,1):crop_limits(1,2)-1, ...
        :);

        % downsample cropped image
        F = F( ...
        1:spatial_downsample:end, ...
        1:spatial_downsample:end, ...
        :);
    
        % Convert to double, output to 4D array
        if load_grayscale
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
% if vidObj.FrameRate ~= params_input.fps
%     vid_t = vid_t * (vidObj.FrameRate / params_input.fps);
% end

end