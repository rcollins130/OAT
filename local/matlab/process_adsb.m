
function adsb_tracks = process_adsb(record, adsb_process, mapping)
    %% Load databases
    icao_table = load_icao_table(adsb_process.icao_database_filepath);
    dim_table = load_dimension_table(adsb_process.dimension_database_filepath);
    
    %% Load ADS-B Tracks
    fname = strcat( ...
        fullfile( ...
            adsb_process.adsb_basepath, ...
            record ...
        ), ...
        adsb_process.extension ...
    );
    all_adsb_tracks = parse_adsb1090(fname);
    
    %% Find Tracks of Interest
    adsb_tracks = filter_adsb_tracks(all_adsb_tracks, adsb_process, mapping);
    
    %% Add Enhancement Data to Tracks of Interest
    adsb_tracks = enhance_adsb_tracks(adsb_tracks, icao_table, dim_table, mapping);
    
end