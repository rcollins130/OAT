function enhanced_tracks = enhance_adsb_tracks(raw_tracks, icao_table, dimension_table, mapping)
%ENHANCE_ADSB_TRACKS Summary of this function goes here
%   Detailed explanation goes here

    enhanced_tracks = struct( ...
        "icao",{}, ...
        "id",{}, ...
        "typedata",{},...
        "aircraft_dimensions",{},...
        "pos_t", [], ...
        "pos",[], ...
        "alt_t",[], ...
        "alt", [], ...
        "azi", [],...
        "vel_t", [], ...
        "vel",[] ...
        );

    
    for ii_t=1:size(raw_tracks,2)
        %% fill in existing fields
        enhanced_tracks(ii_t).icao = raw_tracks(ii_t).icao;
        enhanced_tracks(ii_t).id = raw_tracks(ii_t).id;
        enhanced_tracks(ii_t).pos_t = raw_tracks(ii_t).pos_t;
        enhanced_tracks(ii_t).pos = raw_tracks(ii_t).pos;
        enhanced_tracks(ii_t).alt_t = raw_tracks(ii_t).alt_t;
        enhanced_tracks(ii_t).alt = raw_tracks(ii_t).alt;
        enhanced_tracks(ii_t).vel_t = raw_tracks(ii_t).vel_t;
        enhanced_tracks(ii_t).vel = raw_tracks(ii_t).vel;

        %% get azimuthal position of aircraft
        wgs84 = wgs84Ellipsoid("meter");
        cam_pt = [mapping.camera_geo_pos(2), mapping.camera_geo_pos(1)];

        enhanced_tracks(ii_t).azi = distance( ...
            repmat(cam_pt,[size(enhanced_tracks(ii_t).pos,1),1]), ...
            enhanced_tracks(ii_t).pos, ...
            wgs84 ...
        );

        %% get aircraft type
        icao_idx = find(icao_table.icao24 == enhanced_tracks(ii_t).icao,1);
        if ~isempty(icao_idx)
            enhanced_tracks.typedata = table2struct(icao_table(icao_idx,:));
        else
            warning("Could not find icao address '%s' in icao_table", enhanced_tracks(ii_t).icao);
        end
        
        %% get aircraft dimensions
        if ~isempty(enhanced_tracks(ii_t).typedata)
            dim_idx = find(dimension_table.typecode == enhanced_tracks(ii_t).typedata.typecode,1);
            if ~isempty(dim_idx)
                enhanced_tracks.aircraft_dimensions = table2struct(dimension_table(dim_idx,2:4));
            else
                warning("Could not find typecode '%s' in dimension_table", enhanced_tracks(ii_t).typedata.typecode);
                disp("try: https://skybrary.aero/aircraft/%s", enhanced_tracks(ii_t).typedata.typecode);
            end
        end

    end

end
