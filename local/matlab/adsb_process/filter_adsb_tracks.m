function adsb_tracks = filter_adsb_tracks(all_adsb_tracks, adsb_process, mapping)
%FILTER_ADSB_TRACKS Summary of this function goes here
%   Detailed explanation goes here

valid_tracks = ones(size(all_adsb_tracks,2),1,'logical');

% Filter by ICAO (manual filtering)
if ~isempty(adsb_process.filter_icao)
    for ii_t=1:size(all_adsb_tracks, 2)
        if ~valid_tracks(ii_t)
            continue
        end
        valid_tracks(ii_t) = any(adsb_process.filter_icao == all_adsb_tracks(ii_t).icao);
    end
end

% Filter by height of interest
for ii_t=1:size(all_adsb_tracks, 2)
    if ~valid_tracks(ii_t)
        continue
    end
    if adsb_process.filter_alt_strict
        valid = all(all_adsb_tracks(ii_t).alt > mapping.geo_alt_lims_ft(1) & ...
                    all_adsb_tracks(ii_t).alt < mapping.geo_alt_lims_ft(2));
    else
        valid = any(all_adsb_tracks(ii_t).alt > mapping.geo_alt_lims_ft(1) & ...
                    all_adsb_tracks(ii_t).alt < mapping.geo_alt_lims_ft(2));
    end
    valid_tracks(ii_t) = valid;
end

% Filter by geo domain
for ii_t=1:size(all_adsb_tracks, 2)
    if ~valid_tracks(ii_t)
        continue
    end
    pts = geopointshape(all_adsb_tracks(ii_t).pos(:,1), all_adsb_tracks(ii_t).pos(:,2));
    if adsb_process.filter_domain_strict
        valid = all(isinterior(mapping.geo_domain_poly, pts));
    else
        valid = any(isinterior(mapping.geo_domain_poly, pts));
    end
    valid_tracks(ii_t) = valid;
end

% TODO: May want additional filters, such as headings, speed, types, etc.


adsb_tracks = all_adsb_tracks(valid_tracks);

end

