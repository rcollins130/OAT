function vid_nbg = video_subtract_background_and_normalize(vid_cdata, vid_background, video_process)
%SUBTRACT_BACKGROUND_AND_NORMALIZE Summary of this function goes here
%   Detailed explanation goes here

vid_nbg = vid_cdata - vid_background;

if video_process.normalize_abs
    vid_nbg = abs(vid_nbg);
end

if video_process.normalization_method == "all"
    vid_nbg = vid_nbg - min(vid_nbg,[],'all');
    vid_nbg = vid_nbg ./ max(vid_nbg, [], 'all');
else
    error("Unknown video_process.background_method %s", video_process.normalization_method)
end

end

