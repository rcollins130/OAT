function process_record(record, publish)

publish.recordpath = fullfile(publish.basepath, record);

if ~exist(publish.recordpath, 'dir')
    mkdir(publish.recordpath)
end

adsb_process = adsb_params(record);
mapping = mapping_params(record);
video_process = video_params(record);

%% Process ADS-B and Video Data
adsb_tracks = process_adsb(record, adsb_process, mapping);
[video_tracks, vid_cdata, vid_times] = process_video(record, video_process, mapping);

%% Associate ADS-B and Video Tracks
vid2adsb = associate_tracks(adsb_tracks, video_tracks);

% if publish.do_pub
% figure(1); clf; set(gcf,'Position',[50,50, 800, 650])
% plot_track_formation([], vid_cdata, vid_times, video_tracks, fullfile(publish.recordpath, 'track_formation.mp4'));
% end
%% Aircraft Velocity Analysis
track_velocities = struct('time',[],'speed',[],'smooth_speed',[]);
for ii_at = 1:size(adsb_tracks,2)
    % get aircraft length, m
    aircraft_length_m = adsb_tracks(ii_at).aircraft_dimensions.length_m;

    % get mean aircraft speed in bounding box lengths 
    % loop through each video track
    speeds = {};
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
        v_kts = v_bb * aircraft_length_m * 1.94;
        
        ii_smooth = [ii_ts(1),ii_ts(end)];
        dt_s_sm = seconds(diff(video_tracks(ii_vt).times(ii_smooth)));
        v_px_sm = diff(video_tracks(ii_vt).centroids(ii_smooth,:),1) ./ dt_s_sm;
        v_bb_sm = v_px_sm ./ mean(video_tracks(ii_vt).bbs(ii_smooth,3));
        v_kts_sm = v_bb_sm * aircraft_length_m * 1.94;

        track_velocities(ii_at).time = [track_velocities(ii_at).time, video_tracks(ii_vt).times(ii_ts(1:end-1))];
        track_velocities(ii_at).speed = [track_velocities(ii_at).speed, abs(v_kts(:,1))];
        track_velocities(ii_at).smooth_speed = abs(v_kts_sm(1));
    end

    % figure(2); clf; set(gcf,'Position',[50,50, 650, 800])
    % subplot(2,1,1)
    % imshow(vid_cdata(:,:,:,video_tracks(ii_vt).frame_idxs(ii_ts(end))))
    % hold on
    % plot(video_tracks(ii_vt).centroids(:,1), video_tracks(ii_vt).centroids(:,2))
    % title(sprintf("Record %s Selected Track", record),'Interpreter','none')
    % subplot(2,1,2); hold on
    % plot(adsb_tracks.vel_t, adsb_tracks.vel(:,2), 'LineWidth',2, 'DisplayName','ADS-B Broadcast Velocity')
    % plot(track_velocities.time, track_velocities.speed,'--', 'DisplayName','Per-Frame Computed Velocity')
    % %plot(track_velocities.time, movmean(track_velocities.speed, 10), '--', 'DisplayName', '... 10-pt Running Average ')
    % plot(track_velocities.time, movmean(track_velocities.speed, 50), 'k','LineWidth',2, 'DisplayName', '... 50-pt Running Average ')
    % %plot(track_velocities.time, ones(size(track_velocities.time))*track_velocities.smooth_speed, 'LineWidth', 2, 'DisplayName', 'Start-Finish Mean Speed')
    % legend()
    % xlim([track_velocities.time(1)-seconds(10), track_velocities.time(end)+seconds(10)])
    % ylabel('Airspeed, kts')
    % xlabel('Time, UTC')
    % if publish.do_pub
    %     saveas(gcf, fullfile(publish.recordpath, sprintf('track_%d_velocity_plot.png', ii_at)))
    % end

    figure(3); clf; set(gcf,'Position',[50,50, 800, 650])
    plot_track_closeup([], vid_cdata, vid_times, ...
        video_tracks(ii_vt), adsb_tracks(ii_at), ...
        fullfile(publish.recordpath, sprintf('atrack_%d_vtrack_%d.mp4', ii_at, ii_vt)))
end

%% Save data
if publish.do_pub
    save(fullfile(publish.recordpath, sprintf('workspace.mat')))
end

end