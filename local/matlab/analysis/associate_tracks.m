function vid2adsb = associate_tracks(adsb_tracks, video_tracks)
%ASSOCIATE_TRACKS Summary of this function goes here
%   Detailed explanation goes here

% todo: implement this function

if size(adsb_tracks,2) > 1
    error("associate_tracks not implemented for adsb track lists longer than 1")
end

vid2adsb = ones(size(video_tracks));

end

