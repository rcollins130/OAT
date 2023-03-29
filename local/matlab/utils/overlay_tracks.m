
input_dir = 'data/movie';

% multitrack
records = [
    "20230321_194339";%
    "20230321_194950";%
    "20230321_195551";%
    "20230321_200127";%
    "20230321_200549";%
    "20230322_142550";%
    "20230322_150057";
    "20230322_151255";
    "20230322_151422";
    "20230322_152037";
    "20230322_152347";%
    "20230322_152805";
    "20230322_153053";
    "20230322_153437";
    "20230322_153924";
    "20230322_154324";
    "20230322_154557";
    "20230322_154747";
    "20230322_155108";%
    "20230322_155502";%
    "20230322_155935";
    "20230322_162225";%
    ];

n_records = size(records,1);

vid_tracks = cell(n_records, 1);

for ii_r = 1:n_records
    record = records(ii_r);
    fprintf("Processing %s (%d/%d)\n", record, ii_r, n_records);

    adsb_process = adsb_params(record);
    mapping = mapping_params(record);
    video_process = video_params(record);

    %adsb_tracks = process_adsb(record, adsb_process, mapping);
    if ii_r==1
        [vid_tracks{ii_r}, vid_cdata, ~] = process_video(record, video_process, mapping);
        bg = video_compute_background(vid_cdata,4,video_process);
    else
        [vid_tracks{ii_r}, ~, ~] = process_video(record, video_process, mapping);
    end
end

clf;
imshow(bg); hold on;
for ii_r = 1:n_records
    for ii_t = 1:size(vid_tracks{ii_r},2)
        if any(ii_r==[16,21]); continue; end

        plot(vid_tracks{ii_r}(ii_t).centroids(:,1), vid_tracks{ii_r}(ii_t).centroids(:,2),'LineWidth',3)
    end
end
