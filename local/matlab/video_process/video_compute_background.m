function vid_background = video_compute_background(vid_cdata, time_dim, video_process)
%COMPUTE_BACKGROUND Summary of this function goes here
%   Detailed explanation goes here

if video_process.background_method == "median"
    vid_background = median(vid_cdata, time_dim);
elseif video_process.background_method == "strel"
    warning("video_process.background_method 'strel' is experimental")
    vid_background = zeros(size(vid_cdata));
    shp = size(vid_background); shp(3)=1;
    for ii_c=1:size(vid_cdata,3)
        vid_background(:,:,ii_c,:) = reshape(...
        imerode(squeeze(vid_cdata(:,:,ii_c,:)),strel('cuboid',[10,10,10])),shp...
        );
    end
else
    error("Unknown video_process.background_method %s", video_process.background_method)
end

% TODO: ADD STREL BACKGROUND

end

