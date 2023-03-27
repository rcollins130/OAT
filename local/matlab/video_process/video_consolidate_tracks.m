function combined_tracks = video_consolidate_tracks(vid_tracks, video_process)
%VIDEO_COMBINE_TRACKS Summary of this function goes here
%   Detailed explanation goes here

if video_process.consolidation_method == "manual"
    for ii_c =1:size(video_process.manual_consolidation,1)
        to_combine = vid_tracks(video_process.manual_consolidation{1});
        combined_tracks(ii_c) = combine_tracks(to_combine);
    end
elseif video_process.consolidation_method == "none" || video_process.consolidation_method == ""
    combined_tracks = vid_tracks;
else
    error("Unknown video_process.consolidatation_method %s", video_process.consolidatation_method)
end

end

function combined_track = combine_tracks(tracks)
    % todo: do this more efficiently
    combined_track.frame_idxs = [];
    combined_track.region_idxs = [];
    combined_track.times = [];
    combined_track.centroids = [];
    combined_track.bbs = [];

    for ii_t=1:size(tracks,2)
        combined_track.frame_idxs = [combined_track.frame_idxs; tracks(ii_t).frame_idxs];
        combined_track.region_idxs = [combined_track.region_idxs; tracks(ii_t).region_idxs];
        combined_track.times = [combined_track.times; tracks(ii_t).times];
        combined_track.centroids = [combined_track.centroids; tracks(ii_t).centroids];
        combined_track.bbs = [combined_track.bbs; tracks(ii_t).bbs];
    end

    % track.frame_idxs = [track1.frame_idxs; track2.frame_idxs];
    % track.region_idxs = [track1.region_idxs; track2.region_idxs];
    % track.times = [track1.times; track2.times];
    % track.centroids = [track1.centroids; track2.centroids];
    % track.bbs = [track1.bbs; track2.bbs];
end