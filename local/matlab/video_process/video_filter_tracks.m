function [filtered_tracks] = video_filter_tracks(vid_tracks, video_tracking)
%VIDEO_FILTER_TRACKS Summary of this function goes here
%   Detailed explanation goes here

f = fieldnames(vid_tracks)';
f{2,1} = {};
ii_ft = 1;
filtered_tracks = struct(f{:});

for ii_t = 1:size(vid_tracks, 2)
    if size(vid_tracks(ii_t).frame_idxs,1)>= video_tracking.track_filter_length
        filtered_tracks(ii_ft) = vid_tracks(ii_t);
        ii_ft = ii_ft+1;
    end
end

end

