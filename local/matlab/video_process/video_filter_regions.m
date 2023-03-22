function [filt_regions, max_region_area] = video_filter_regions(regions, max_region_area, video_tracking)
%VIDEO_FILTER_REGIONS Summary of this function goes here
%   Detailed explanation goes here

if video_tracking.filter_regions_by_area
    filt_regions = cell(size(regions));
    %n_reg = zeros(size(regions));
    for ii_f = 1:size(regions, 1)
        if size(regions{ii_f},1)>0
            filt_idx = [regions{ii_f}.Area] > max_region_area*video_tracking.filter_regions_area_scale;
            filt_regions{ii_f} = regions{ii_f}(filt_idx);
            %n_reg(ii_f)=size(regions{ii_f},1);
        end
    end
else
    filt_regions = regions;
end

end

