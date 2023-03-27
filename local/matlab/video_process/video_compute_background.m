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
elseif video_process.background_method == "local_median"
    warning("video_process.background_method 'local_median' is experimental")
    vid_background = zeros(size(vid_cdata));
    window = 100;
    skip = 10;
    for ii_f=1:skip:size(vid_cdata, time_dim)
        low_l = max(ii_f-window, 1);
        high_l = min(ii_f+window, size(vid_cdata,4));
        this_skip = min(ii_f+skip, size(vid_cdata,4));
        sz = this_skip-ii_f+1;
        vid_background(:,:,:,ii_f:this_skip) = repmat(median(vid_cdata(:,:,:,low_l:high_l), time_dim),1,1,1,sz);
    end
else
    error("Unknown video_process.background_method %s", video_process.background_method)
end

% TODO: ADD STREL BACKGROUND

end

