function [regions, max_region_area] = video_identify_regions(vid_bin, video_process)
%VIDEO_IDENTIFY_REGIONS Summary of this function goes here
%   Detailed explanation goes here

    regions = cell(size(vid_bin, 3),1);
    max_region_area = 0;

    for ii_frame = 1:size(vid_bin, 3)
    
        CC = bwconncomp(vid_bin(:,:,ii_frame));
    
        sub_stats = regionprops(CC);
        regions{ii_frame} = sub_stats;
        if size(sub_stats,1)>=1
            max_region_area = max(max_region_area, max([sub_stats.Area]));
        end
    end

end

