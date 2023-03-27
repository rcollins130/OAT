function adsb_process = adsb_params(~)
%ADSB_PARAMS Summary of this function goes here
%   Detailed explanation goes here
adsb_process.adsb_basepath = 'data/adsb/';
adsb_process.extension = '.adsb';

adsb_process.filter_alt_strict = 0;
adsb_process.filter_domain_strict = 0;

adsb_process.icao_database_filepath = 'database/aircraftDatabase-2023-03.csv';
adsb_process.dimension_database_filepath = 'database/aircraft_dimension_database.xlsx';

end

