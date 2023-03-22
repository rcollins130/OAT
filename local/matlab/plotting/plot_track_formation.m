function plot_track_formation(ax, vid_cdata, vid_times, tracks)
%PLOT_TRACK_FORMATION Summary of this function goes here
%   Detailed explanation goes here

if isempty(ax)
    im = imshow(vid_cdata(:,:,:,1));
    ax = im.Parent;
else
    im = imshow(vid_cdata(:,:,:,1), 'Parent', ax);
end

plot_regions = {};
track_traces = {};

for ii_f=2:size(vid_cdata, 4)
    im.CData = vid_cdata(:,:,:,ii_f);
    title(string(vid_times(ii_f)));
    
    if ~isempty(plot_regions)
        delete(plot_regions);
        plot_regions = {};
    end

    for tid=1:size(tracks,2)
        ii_tf = find(tracks(tid).frame_idxs==ii_f);
        ii_lf = find(tracks(tid).frame_idxs==ii_f-1);
        if isempty(ii_tf)
            continue
        end

        hold on
        if tid>size(track_traces,2)
            track_traces{tid} = plot( ...
                tracks(tid).centroids(ii_tf,1), ...
                tracks(tid).centroids(ii_tf,2) ...
            );
            text(tracks(tid).centroids(ii_tf,1), ...
                tracks(tid).centroids(ii_tf,2), ...
                sprintf("Track %d",tid), ...
                "BackgroundColor",'w')
        end

        % plot regions in this frame 
        for ii_r=ii_tf'
            bb = tracks(tid).bbs(ii_r,:);
            ps = polyshape([bb(1),bb(1),bb(1)+bb(3),bb(1)+bb(3)], ...
            [bb(2),bb(2)+bb(4),bb(2)+bb(4),bb(2)]);
            pg = plot(ps,'FaceColor','g','FaceAlpha',0.25,'LineStyle','none');
            plot_regions = [plot_regions, pg];

            track_traces{tid}.XData = [...
                track_traces{tid}.XData, tracks(tid).centroids(ii_tf,1)'...
            ];
            track_traces{tid}.YData = [...
                track_traces{tid}.YData, tracks(tid).centroids(ii_tf,2)'...
            ];
        end
        % plot regions in last frame
        for ii_r=ii_lf'
            bb = tracks(tid).bbs(ii_r,:);
            ps = polyshape([bb(1),bb(1),bb(1)+bb(3),bb(1)+bb(3)], ...
            [bb(2),bb(2)+bb(4),bb(2)+bb(4),bb(2)]);
            pg = plot(ps,'FaceColor','r','FaceAlpha',0.25,'LineStyle','none');
            plot_regions = [plot_regions, pg];
        end
        hold off

    end
    drawnow
end

end

