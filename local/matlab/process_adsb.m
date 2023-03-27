
% outline for processing ads-b data

%% Parameters
par.adsb_process.adsb_basepath = 'data/adsb/';
par.adsb_process.record = '20230317_145402';
par.adsb_process.extension = '.adsb';

par.adsb_process.filter_alt_strict = 0;
par.adsb_process.filter_domain_strict = 0;

par.adsb_process.icao_database_filepath = 'database/aircraftDatabase-2023-03.csv';
par.adsb_process.dimension_database_filepath = 'database/aircraft_dimension_database.xlsx';

par.mapping = mapping_params();

%% Load databases
icao_table = load_icao_table(par.adsb_process.icao_database_filepath);
dim_table = load_dimension_table(par.adsb_process.dimension_database_filepath);

%% Load ADS-B Tracks
fname = strcat( ...
    fullfile(par.adsb_process.adsb_basepath, par.adsb_process.record), ...
    par.adsb_process.extension);
all_adsb_tracks = parse_adsb1090(fname);

%% Find Tracks of Interest
adsb_tracks = filter_adsb_tracks(all_adsb_tracks, par.adsb_process, par.mapping);

%% Add Enhancement Data to Tracks of Interest
adsb_tracks = enhance_adsb_tracks(adsb_tracks, icao_table, dim_table);

%% Return adsb_tracks