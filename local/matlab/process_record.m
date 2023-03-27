clear
record = '20230317_145402';

%% Parameters
adsb_process = adsb_params(record);
mapping = mapping_params(record);
video_process = video_params(record);

%% Process ADS-B and Video Data
adsb_tracks = process_adsb(record, adsb_process, mapping);
[video_tracks, vid_cdata, vid_times] = process_video(record, video_process, mapping);

%% Associate ADS-B and Video Tracks
vid2adsb = associate_tracks(adsb_tracks, video_tracks);

%% Aircraft Velocity Analysis
for ii_at = 1:size(adsb_tracks,2)
    % get aircraft length, m
    aircraft_length_m = adsb_tracks(ii_at).aircraft_dimensions.length_m;

    % get mean aircraft speed in bounding box lengths 
    % loop through each video track
    for ii_vt = 1:size(video_tracks ,2)
        % skip if not associated with this ads-b track
        if vid2adsb(ii_vt) ~= ii_at
            continue
        end
        % % get unique times on this video track
        % %   todo: would be nice to clean up the vid tracks in process_video
        % % TODO: HANDLE THIS
        % [t, ia, ic] = unique(video_tracks);
        % for ii_t=ia
        % 
        % end
        
        % get regions where bounding box is consistent size
        med_w = median(video_tracks(ii_vt).bbs(:,3));
        ii_ts = find(abs(video_tracks(ii_vt).bbs(:,3)-med_w)<(0.1*med_w));
        
        dt_s = seconds(diff(video_tracks(ii_vt).times(ii_ts)));
        v_px = diff(video_tracks(ii_vt).centroids(ii_ts,:),1) ./ dt_s;
        v_bb = v_px ./ video_tracks(ii_vt).bbs(ii_ts(1:end-1),3);
        v_mps = v_bb * aircraft_length_m;
    end
end
 