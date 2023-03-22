function plot_regions(ax, vid_cdata, vid_times, regions)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if isempty(ax)
    im = imshow(vid_cdata(:,:,:,1));
    ax = im.Parent;
else
    im = imshow(vid_cdata(:,:,:,1), 'Parent', ax);
end

plot_regions = {};
for ii_f = 1:size(vid_cdata ,4)
    title(string(vid_times(ii_f)))
    im.set('CData', vid_cdata(:,:,:,ii_f), 'Parent', ax);
    
    if ~isempty(plot_regions)
        delete(plot_regions);
        plot_regions = {};
    end

    frame_regions = regions{ii_f};
    for ii_reg=1:size(frame_regions,1)
        bb = frame_regions(ii_reg).BoundingBox;
        hold on
        % plot( ...
        %     [bb(1),bb(1),bb(1)+bb(3),bb(1)+bb(3),bb(1)], ...
        %     [bb(2),bb(2)+bb(4),bb(2)+bb(4),bb(2),bb(2)],'r-')
        ps = polyshape([bb(1),bb(1),bb(1)+bb(3),bb(1)+bb(3)], ...
            [bb(2),bb(2)+bb(4),bb(2)+bb(4),bb(2)]);
        pg = plot(ps,'FaceColor','r','FaceAlpha',0.1,'EdgeColor','r');
        plot_regions = [plot_regions, pg];
        hold off
    end

    drawnow()
end

end

