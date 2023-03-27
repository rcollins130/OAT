
record = "20230317_145402";

adsb_process = adsb_params(record);
mapping = mapping_params(record);
video_process = video_params(record);

adsb_tracks = process_adsb(record, adsb_process, mapping);

[vid_tracks, vid_cdata, vid_times] = process_video( ...
    record, video_process, mapping);


