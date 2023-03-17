%%%
% 
% Script for parsing messages from current custom fork of adsb1090. Script
%   reads raw lines from adsb1090 stdout and forms tracks, performing CPR
%   location calculations. 
% Longer term, much of this script should be moved to a custom fork of 
%   the adsb1090 library. adsb1090 already has good CPR location algos 
%   (this implementation is copied from there) and can parse many more
%   types of messages.
function tracks = parse_adsb1090(lines, par)
    % Parameters and constants
    ESQT_POS = 11;
    ESQT_VEL = 19;
    ESQT_ID = 4;


    % Group Provided Lines into messages
    raw_m = {};
    this_m = {};
    for ii=1:length(lines)
        test_str = lines(ii);
        
        % on newline, append this_m to raw_m
        if test_str==""
            raw_m{length(raw_m)+1} = this_m;
            this_m = {};
        else
            this_m{length(this_m)+1} = test_str;
        end
    end

    % Drop last message
    %   Current adsb1090 scripts run adsb1090 for fixed duration, which
    %   may termiante the program while it is outputting a line. Dropping
    %   last message prevents partial-message errors. Dropping single 
    %   message has little cost. 
    raw_m = raw_m(1:end-1);
    
    % Parse relevant message fields to a Table for easy filtering.
    %   Only parse id, position, and velocity messages. 
    % base fields
    vt_base = ["string","datetime","int8", "string","string"];
    vn_base = ["code", "time", "esqt", "esqn","icao"];
    % id fields
    vt_id = ["string","string"];
    vn_id = ["AircraftType","Identification"];
    % position fields
    vt_pos = ["string","string","double","double","double"];
    vn_pos = ["Fflag","Tflag","alt","lat_uc","lon_uc"];
    % velocity fields
    vt_vel = ["double","double","double","double", ...
              "double","double","double"];
    vn_vel = ["ew_dir","ew_vel","ns_dir","ns_vel", ...
              "vr_src","vr_sign","vr_rate"];
    
    % function for generating new message table
    vt = [vt_base, vt_id, vt_pos, vt_vel];
    vn = [vn_base, vn_id, vn_pos, vn_vel];
    maket = @(n)(table('Size',[n,length(vt)],'VariableTypes',vt,'VariableNames',vn));
    
    % parse messages
    msg_data = maket(0);
    for ii_m = 1:length(raw_m)
        m_lines = raw_m{ii_m};
    
        msg_row = maket(1);
        for ii_l = 1:length(m_lines)
            test_str = m_lines{ii_l};
            % extract message code
            if extract(test_str, 1) == "*"
                msg_row.code = extractBetween(test_str, "*", ";");
            % ignore lines without key-val separator
            elseif ~contains(test_str,": ")
                continue
            % extract message key-val pairs
            else
                parts = test_str.split(": ");
                key = replace(parts(1)," ","");
                val = parts(2);
    
                % base fields
                if key=="DT_ms"
                    msg_row.time = datetime(str2double(val)/1000,'ConvertFrom','posixtime');
                elseif key=="ICAOAddress"
                    msg_row.icao = val;
                elseif key=="ExtendedSquitterType"
                    msg_row.esqt = str2double(val);
                elseif key=="ExtendedSquitterName"
                    msg_row.esqn = val;
    
                % id fields
                elseif key=="AircraftType"
                    msg_row.AircraftType = val;
                elseif key=="Identification"
                    msg_row.Identification = val;
                   
                % position fields
                elseif key=="Fflag"
                    msg_row.Fflag = val;
                elseif key=="Tflag"
                    msg_row.Tflag = val;
                elseif key=="Altitude"
                    msg_row.alt = str2double(replace(val," feet",""));
                elseif key=="Latitude"
                    msg_row.lat_uc = str2double(replace(val," (not decoded)",""));
                elseif key=="Longitude"
                    msg_row.lon_uc = str2double(replace(val," (not decoded)",""));
                
                % velocity fields
                elseif key=="EWdirection"
                    msg_row.ew_dir = str2double(val);
                elseif key=="EWvelocity"
                    msg_row.ew_vel = str2double(val);
                elseif key=="NSdirection"
                    msg_row.ns_dir = str2double(val);
                elseif key=="NSvelocity"
                    msg_row.ns_vel = str2double(val);
                elseif key=="Verticalratesrc"
                    msg_row.vr_src = str2double(val);
                elseif key=="Verticalratesign"
                    msg_row.vr_sign = str2double(val);
                elseif key=="Verticalrate"
                    msg_row.vr_rate = str2double(val);
                end
            end
        end
        % Only pull out position, velocity, id esqts
        if ~ismissing(msg_row.esqt) && any(msg_row.esqt==[ESQT_POS, ESQT_ID, ESQT_VEL])
            msg_data(height(msg_data)+1,:) = msg_row;
        end
    end

    % form aircraft tracks
    tracks = struct( ...
        "icao",{}, ...
        "type",{}, ...
        "id",{}, ...
        "pos_t", [], ...
        "pos",[], ...
        "alt_t",[], ...
        "alt", [], ...
        "vel_t", [], ...
        "vel",[], ...
        "ocpr_t", [], ...
        "ocpr_ll",[], ...
        "ecpr_t",[], ...
        "ecpr_ll",[]);

    for ii_m=1:height(msg_data)
        msg_row = msg_data(ii_m,:);
        % determine if we have a track associated with this aircraft
        %   if not, add one. 
        if height(tracks)<1
            tracks(1).icao = msg_row.icao;
            ii_t = 1;
        else
            ii_t = find([tracks.icao]==msg_row.icao,1);
            if isempty(ii_t)
                ii_t = size(tracks,2)+1;
                tracks(ii_t).icao = msg_row.icao;
            end
        end
    
        % if position message
        if msg_row.esqt == ESQT_POS
            % Add altitude
            %   note- we only add an alt entry when we have good position
            %   this is not necessary, but makes postproc easier. 
                % tracks(ii_t).alt_t = [tracks(ii_t).alt_t; msg_row.time];
                % tracks(ii_t).alt = [tracks(ii_t).alt; msg_row.alt];

            % Update even/odd CPR entries
            if msg_row.Fflag=="even"
                tracks(ii_t).ecpr_t = msg_row.time;
                tracks(ii_t).ecpr_ll = [msg_row.lat_uc, msg_row.lon_uc];
            else
                tracks(ii_t).ocpr_t = msg_row.time;
                tracks(ii_t).ocpr_ll = [msg_row.lat_uc, msg_row.lon_uc];
            end
            
            % if we have good CPR pair, do CPR positioning
            if (~isempty(tracks(ii_t).ecpr_t) && ~isempty(tracks(ii_t).ocpr_t) && ...
                abs(tracks(ii_t).ecpr_t - tracks(ii_t).ocpr_t) <= seconds(10))
                [lat,lon] = decodeCPR( ...
                    tracks(ii_t).ecpr_t, tracks(ii_t).ecpr_ll, ...
                    tracks(ii_t).ocpr_t, tracks(ii_t).ocpr_ll);
                
                if ~isempty([lat,lon])
                    tracks(ii_t).pos_t = [tracks(ii_t).pos_t; msg_row.time];
                    tracks(ii_t).pos = [tracks(ii_t).pos; [lat,lon]];
                    % NOTE: only add when CPR position calculated
                    tracks(ii_t).alt_t = [tracks(ii_t).alt_t; msg_row.time];
                    tracks(ii_t).alt = [tracks(ii_t).alt; msg_row.alt];
                end
            end
    
        % if id message
        elseif msg_row.esqt == ESQT_ID
            % assign identification to track
            tracks(ii_t).type = msg_row.AircraftType;
            tracks(ii_t).id = msg_row.Identification;
            % TODO: raise warning if type or identification change
    
        % if velocity message
        elseif msg_row.esqt == ESQT_VEL
            % parse velocity to angular
            ew_vel = (msg_row.ew_dir*2-1)*msg_row.ew_vel;
            ns_vel = (msg_row.ns_dir*2-1)*msg_row.ns_vel;
            vr = (msg_row.vr_sign*2-1)*msg_row.vr_rate;
            heading = atan2(ns_vel, ew_vel);
            speed = norm([ns_vel, ew_vel]);
            
            tracks(ii_t).vel_t = [tracks(ii_t).vel_t; msg_row.time];
            tracks(ii_t).vel = [tracks(ii_t).vel; [heading, speed, vr]];
        end
    end
end

%% CPR HELPER FUNCTIONS
% Adapted from dump1090 cpp code
function [lat, lon] = decodeCPR(t0, ll0, t1, ll1)
    % code adapted from dump1090
    
    AirDlat0 = 360.0 / 60;
    AirDlat1 = 360.0 / 59;
    
    % Compute the Latitude Index ii_lat
    ii_lat = floor(((59*ll0(1) - 60*ll1(1)) / 131072) + 0.5);
    rlat0 = AirDlat0 * (cprModFunction(ii_lat, 60) + ll0(1)/131072);
    rlat1 = AirDlat1 * (cprModFunction(ii_lat, 59) + ll1(1)/131072);

    if (rlat0 >= 270) rlat0 = rlat0-360; end
    if (rlat1 >= 270) rlat1 = rlat1-360; end

    %Check that both are in the same latitude zone, or abort
    if (cprNLFunction(rlat0) ~= cprNLFunction(rlat1)) 
        lat=[];
        lon=[];
        return; 
    end

    % Compute ni and the longitude index m
    if (t0 > t1)
        % Use even packet. */
        ni = cprNFunction(rlat0,0);
        m = floor((((ll0(2) * (cprNLFunction(rlat0)-1)) - ...
                    (ll1(2) * cprNLFunction(rlat0))) / 131072) + 0.5);
        lon = cprDlonFunction(rlat0,0) * (cprModFunction(m,ni)+ll0(2)/131072);
        lat = rlat0;
    else 
        % Use odd packet. */
        ni = cprNFunction(rlat1,1);
        m = floor((((ll0(2) * (cprNLFunction(rlat1)-1)) - ...
                   (ll1(2) * cprNLFunction(rlat1))) / 131072.0) + 0.5);
        lon = cprDlonFunction(rlat1,1) * (cprModFunction(m,ni)+ll1(2)/131072);
        lat = rlat1;
    end
    if (lon > 180) lon = lon - 360; end
end

function res = cprModFunction(a,b)
    res = mod(a,b);
    if (res<0) res = res+b; end
end

function a = cprNLFunction(lat)
    if (lat < 0) lat = -lat; end 
    if (lat < 10.47047130) a= 59; 
    elseif (lat < 14.82817437) a= 58; 
    elseif (lat < 18.18626357) a= 57; 
    elseif (lat < 21.02939493) a= 56; 
    elseif (lat < 23.54504487) a= 55; 
    elseif (lat < 25.82924707) a= 54; 
    elseif (lat < 27.93898710) a= 53; 
    elseif (lat < 29.91135686) a= 52; 
    elseif (lat < 31.77209708) a= 51; 
    elseif (lat < 33.53993436) a= 50; 
    elseif (lat < 35.22899598) a= 49; 
    elseif (lat < 36.85025108) a= 48; 
    elseif (lat < 38.41241892) a= 47; 
    elseif (lat < 39.92256684) a= 46; 
    elseif (lat < 41.38651832) a= 45; 
    elseif (lat < 42.80914012) a= 44; 
    elseif (lat < 44.19454951) a= 43; 
    elseif (lat < 45.54626723) a= 42; 
    elseif (lat < 46.86733252) a= 41; 
    elseif (lat < 48.16039128) a= 40; 
    elseif (lat < 49.42776439) a= 39; 
    elseif (lat < 50.67150166) a= 38; 
    elseif (lat < 51.89342469) a= 37; 
    elseif (lat < 53.09516153) a= 36; 
    elseif (lat < 54.27817472) a= 35; 
    elseif (lat < 55.44378444) a= 34; 
    elseif (lat < 56.59318756) a= 33; 
    elseif (lat < 57.72747354) a= 32; 
    elseif (lat < 58.84763776) a= 31; 
    elseif (lat < 59.95459277) a= 30; 
    elseif (lat < 61.04917774) a= 29; 
    elseif (lat < 62.13216659) a= 28; 
    elseif (lat < 63.20427479) a= 27; 
    elseif (lat < 64.26616523) a= 26; 
    elseif (lat < 65.31845310) a= 25; 
    elseif (lat < 66.36171008) a= 24; 
    elseif (lat < 67.39646774) a= 23; 
    elseif (lat < 68.42322022) a= 22; 
    elseif (lat < 69.44242631) a= 21; 
    elseif (lat < 70.45451075) a= 20; 
    elseif (lat < 71.45986473) a= 19; 
    elseif (lat < 72.45884545) a= 18; 
    elseif (lat < 73.45177442) a= 17; 
    elseif (lat < 74.43893416) a= 16; 
    elseif (lat < 75.42056257) a= 15; 
    elseif (lat < 76.39684391) a= 14; 
    elseif (lat < 77.36789461) a= 13; 
    elseif (lat < 78.33374083) a= 12; 
    elseif (lat < 79.29428225) a= 11; 
    elseif (lat < 80.24923213) a= 10; 
    elseif (lat < 81.19801349) a= 9; 
    elseif (lat < 82.13956981) a= 8; 
    elseif (lat < 83.07199445) a= 7; 
    elseif (lat < 83.99173563) a= 6; 
    elseif (lat < 84.89166191) a= 5; 
    elseif (lat < 85.75541621) a= 4; 
    elseif (lat < 86.53536998) a= 3; 
    elseif (lat < 87.00000000) a= 2;
    else a= 1; end
end

function a=cprNFunction(lat, isodd)
    a= cprNLFunction(lat)-isodd;
    if (a<1) a=1; end
end

function a=cprDlonFunction(lat, isodd)
    a= 360.0 / cprNFunction(lat, isodd);
end
