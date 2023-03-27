function icao_table = load_icao_table(icao_table_filepath, adsb_process)
%LOAD_ICAO_DB Summary of this function goes here
%   Detailed explanation goes here

opts = detectImportOptions(icao_table_filepath);
opts.SelectedVariableNames = {
    'icao24';
    'registration';
    'manufacturericao';
    'model';
    'typecode';
    'owner';
    };


icao_table = readtable(icao_table_filepath, opts);

end

