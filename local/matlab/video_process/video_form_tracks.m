function [vid_tracks] = video_form_tracks(regions, vid_times, video_tracking)
%VIDEO_FORM_TRACKS Summary of this function goes here
%   Detailed explanation goes here

vid_tracks = struct('frame_idxs',[],'region_idxs',[],'times',[],'centroids',[],'bbs',[]);
next_tid = 1;
region_tracks = cell(size(regions,1),1);
% initialize first regions
region_tracks{1} = zeros(size(regions{1},1));

% frame index
for ii_f = 2:size(regions,1)
    region_tracks{ii_f} = zeros(size(regions{ii_f},1));
    this_regions = regions{ii_f};
    last_regions = regions{ii_f-1};
    
    for ii_tr = 1:size(this_regions,1)
        for ii_lr = 1:size(last_regions,1)
            % test for overlap - break this out to function
            %   think deeper about how this works? 
            if video_tracking.region_overlap_method == "bounding_box_overlap"
                overlap = test_bounding_box_overlap(this_regions(ii_tr), last_regions(ii_lr));
            elseif video_tracking.region_overlap_method == "centroid_containment"
                overlap = test_centroid_containment(this_regions(ii_tr), last_regions(ii_lr));
            else
                error("Unknown video_tracking.region_overlap_method %s", video_tracking.region_overlap_method)
            end

            % todo: what to do if two tracks intersect on a bounding box?

            if overlap
                % check if last region is on a track
                tid = region_tracks{ii_f-1}(ii_lr);
                if tid==0
                    % this is a new track, assign last region to it
                    tid=next_tid; next_tid= tid+1;
                    vid_tracks(tid) = initialize_track();
                    vid_tracks(tid) = add_region_to_track( ...
                        vid_tracks, tid, ...
                        last_regions, ii_lr, ...
                        vid_times, ii_f-1 ...
                        );
                    region_tracks{ii_f-1}(ii_lr) = tid;
                end
                % assign track to region
                vid_tracks(tid) = add_region_to_track( ...
                    vid_tracks, tid, ...
                    this_regions, ii_tr, ...
                    vid_times, ii_f ...
                );
                region_tracks{ii_f}(ii_tr) = tid;

                % todo: may want to do track processing / stats here?
            end
        end
    end
end

end

function track = initialize_track
    track = struct( ...
        'frame_idxs', [], ...
        'region_idxs', [],...
        'times', datetime.empty, ...
        'centroids', zeros([0,2]),...
        'bbs', zeros([0,4])...
    );
end

function track = add_region_to_track(tracks, tid, regions, ii_region, vid_times, ii_frame)
    track = tracks(tid);
    region = regions(ii_region);

    track.frame_idxs = [track.frame_idxs; ii_frame];
    track.region_idxs = [track.region_idxs; ii_region];
    track.times = [track.times; vid_times(ii_frame)];
    track.centroids = [track.centroids; region.Centroid];
    track.bbs = [track.bbs; region.BoundingBox];
end

function overlap = test_bounding_box_overlap(this_region, last_region)
    tr_bb = this_region.BoundingBox;
    lr_bb = last_region.BoundingBox;

    % a: bounding box overlap
    overlap =  (...
        (tr_bb(1) <= lr_bb(1)+lr_bb(3)) && ... % this left <= last right
        (tr_bb(1)+tr_bb(3) >= lr_bb(1)) && ... % this right >= last left
        (tr_bb(2) <= lr_bb(2)+lr_bb(4)) && ...  % this bottom <= last top
        (tr_bb(2)+tr_bb(4) >= lr_bb(2)) ...    % this top >= last bottom
    );
end

function overlap = test_centroid_containment(this_region, last_region)
    overlap = 0;
    error("Function test_centroid_containment not implemented yet")
end
