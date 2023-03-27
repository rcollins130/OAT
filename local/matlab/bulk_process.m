
%% Parameters
publish.do_pub = 1;
publish.basepath = fullfile('media/');

records = [...
    "20230321_162848";
    "20230321_194339";
    "20230321_194950";
    "20230321_195551";
    "20230321_200127";
    "20230321_200549";
    "20230322_142550";
    "20230322_155108";
    "20230322_155502";
    "20230322_162225";
    ];

for record=records'
    % adsb_process = adsb_params(record);
    % mapping = mapping_params(record);
    % adsb_tracks = process_adsb(record, adsb_process, mapping);
    process_record(record, publish)
end