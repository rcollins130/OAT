%% script for determining timing offset of ads-b and video

clear
record = '20230317_145402';

%% Parameters
adsb_process = adsb_params(record);
mapping = mapping_params(record);
video_process = video_params(record);

%% Process ADS-B and Video Data
adsb_tracks = process_adsb(record, adsb_process, mapping);
[video_tracks, vid_cdata, vid_times] = process_video(record, video_process, mapping);

