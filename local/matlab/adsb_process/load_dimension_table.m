function dimension_table = load_dimension_table(dimension_database_filepath,adsb_process)
%LOAD_DIMENSION_TABLE Summary of this function goes here
%   Detailed explanation goes here

opts = detectImportOptions(dimension_database_filepath);
opts = setvartype(opts, "typecode", "string");
opts = setvartype(opts, "source", "string");

dimension_table = readtable(dimension_database_filepath, opts);

end

