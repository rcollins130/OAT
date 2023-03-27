function adsb_process = adsb_params(record)
%ADSB_PARAMS Summary of this function goes here
%   Detailed explanation goes here
adsb_process.adsb_basepath = 'data/adsb/';
adsb_process.extension = '.adsb';

adsb_process.icao_database_filepath = 'database/aircraftDatabase-2023-03.csv';
adsb_process.dimension_database_filepath = 'database/aircraft_dimension_database.xlsx';

adsb_process.filter_alt_strict = 0;
adsb_process.filter_domain_strict = 0;
adsb_process.filter_icao = [];

if record == "20230322_162225"
    adsb_process.filter_icao = ["a91535"];
elseif record == "20230320_203920"
    adsb_process.filter_icao = ["3c4b33"];
end

end

