function vid_bin = video_binarize(vid_nbg, video_process)
%BINARIZE_VIDEO Summary of this function goes here
%   Detailed explanation goes here

if video_process.binarize_method == "percolor"
    vid_cbin = zeros(size(vid_nbg),'logical');
    % remove low-contrast motion
    %   add params for this!
    for ii_c = 1:size(vid_cbin,3)
        vid_cbin(:,:,ii_c,:) = imbinarize(squeeze(vid_nbg(:,:,ii_c,:)));
    end
    
    % 
    vid_cbin_allcolor = squeeze(all(vid_cbin,3));
    vid_cbin_anycolor = squeeze(any(vid_cbin,3));
    
    % vid_cbin_anytime = squeeze(any(vid_cbin,4));
    
    % remove persistent motion 
    %   
    r = video_process.binarize_percolor_dilate_r;
    if video_process.binarize_percolor_mask == "any"
        vid_obin_d = imdilate(vid_cbin_anycolor, strel('sphere',r));
    elseif video_process.binarize_percolor_mask == "all"
        vid_obin_d = imdilate(vid_cbin_allcolor, strel('sphere',r));
    else
        error("Unknown video_process.binarize_percolor_mask %s", video_process.binarize_percolor_mask)
    end
    vid_obin_d_m = mean(vid_obin_d,3);

    %vid_obin_d_mbin = imbinarize(vid_obin_d_m);
    % should scale this based on length/time scale of image compared to jet
    thold = video_process.binarize_percolor_obin_thold;
    vid_obin_d_mask = vid_obin_d_m > thold;
    % note allcolor biases towards white planes
    % NOTE- This caused issues for planes near dusk
    vid_bin = ~vid_obin_d_mask & vid_cbin_allcolor;
    
    r = video_process.binarize_percolor_open_r;
    vid_bin = imopen(vid_bin, strel('disk',r));

    % close image, filling holes in middle
    %   might be abele to skip hole filling
    r = video_process.binarize_percolor_holefill_r;
    se = strel('disk',r);
    vid_bin = imdilate(vid_bin, se);
    vid_bin = imfill(vid_bin, 'holes');
    vid_bin = imerode(vid_bin, se);

else
    error("Unknown video_process.binarize_method %s", video_process.binarize_method)
end

end

