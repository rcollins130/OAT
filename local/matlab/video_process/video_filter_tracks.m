function [filtered_tracks] = video_filter_tracks(vid_tracks, video_process)
%VIDEO_FILTER_TRACKS Summary of this function goes here
%   Detailed explanation goes here

f = fieldnames(vid_tracks)';
f{2,1} = {};
ii_ft = 1;
filtered_tracks = struct(f{:});

% filter video tracks by length (# of frames)
if video_process.track_filter_method == "frames"
    for ii_t = 1:size(vid_tracks, 2)
        if size(vid_tracks(ii_t).frame_idxs,1)>= video_process.track_filter_frame_length
            filtered_tracks(ii_ft) = vid_tracks(ii_t);
            ii_ft = ii_ft+1;
        end
    end
elseif video_process.track_filter_method == "longest"
    ii_longest = 1;
    len_longest = 0;
    for ii_t=1:size(vid_tracks,2)
        len = norm(vid_tracks(ii_t).centroids(1,:) - vid_tracks(ii_t).centroids(end,:));
        if len>len_longest
            ii_longest = ii_t;
            len_longest = len;
        end
    end
    filtered_tracks = vid_tracks(ii_longest);
elseif video_process.track_filter_method == "manual"
    filtered_tracks = vid_tracks(video_process.track_filter_manual_idxs);
else
    error("Unknown video_process.track_filter_method %s", video_process.track_filter_method)
end

end

