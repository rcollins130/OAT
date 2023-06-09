function plot_track_closeup(ax, vid_cdata, vid_times, track, adsb_track, padding, saveto)
%PLOT_TRACK_CLOSEUP Summary of this function goes here
%   Detailed explanation goes here

arguments
    ax
    vid_cdata
    vid_times
    track
    adsb_track = []
    padding = [120,60]
    saveto = []
end

if ~isempty(saveto)
    v = VideoWriter(saveto, 'MPEG-4');
    open(v)
end    


if isempty(ax)
    clf;
    im = imshow(vid_cdata(1:padding(2),1:padding(1),:,1), ...
         'InitialMagnification',2000,'Interpolation',"bilinear");
    ax = im.Parent;
else
    im = imshow(vid_cdata(1:padding(2),1:padding(1),:,1), ...
        'Parent', ax, 'InitialMagnification',2000,'Interpolation',"bilinear");
end

if ~isempty(adsb_track)
    lines = {
        sprintf("ICAO: %s",adsb_track.icao);
        sprintf("Flight Number: %s", adsb_track.id);
        sprintf("Registration: %s", adsb_track.typedata.registration);
        sprintf("Typecode: %s", adsb_track.typedata.typecode);
        sprintf("Aircraft Type: %s %s", adsb_track.typedata.manufacturericao, adsb_track.typedata.model);
        sprintf("Owner: %s", adsb_track.typedata.owner);
        };
        
    t = annotation('textbox', ...
        'Position',[0.1,0.1,0.2,0.2], ...
        'String',lines, ...
        'BackgroundColor','w', ...
        'FontSize',14,...
        'FitBoxToText','on'...
        );
    latlim = [min(adsb_track.pos(:,1))-0.05, max(adsb_track.pos(:,1))+0.05];
    lonlim = [min(adsb_track.pos(:,2))-0.05, max(adsb_track.pos(:,2))+0.05];
    ax2 = geoaxes('Position',[0.1, 0.75, 0.2, 0.2],'Basemap','satellite'); hold on;
    geot = geolineshape(adsb_track.pos(:,1), adsb_track.pos(:,2));
    geoplot(ax2, geot, 'r');
    geolimits(ax2, latlim, lonlim);

    ax3 = axes('Position', [0.1, 0.5, 0.2, 0.2], 'Box', 'on'); hold on;
    plot(ax3, adsb_track.alt_t, adsb_track.alt, 'r');
    ylabel(ax3, 'Altitude, ft');
    xlabel(ax3, 'Time, UTC');
end

for ii_f=1:size(track.frame_idxs,1)
    cent = track.centroids(ii_f,:);
    yidx = max(1,floor(cent(2)-padding(2)/2)):min(size(vid_cdata,1), cent(2)+padding(2)/2);
    xidx = max(1,floor(cent(1)-padding(1)/2)):min(size(vid_cdata,2), cent(1)+padding(1)/2);
    % TODO: pad cdata so we don't clip 
    im.CData = vid_cdata( yidx, xidx,  :,  track.frame_idxs(ii_f));
    title(ax, string(vid_times(track.frame_idxs(ii_f))))
    
    % if ii_f<size(track.frame_idxs,1)
    %     pa = vid_times(track.frame_idxs(ii_f+1))-vid_times(track.frame_idxs(ii_f));
    %     pa = seconds(pa);
    % end
    % pause(pa)
    drawnow()
    if ~isempty(saveto)
        frame = getframe(gcf);
        writeVideo(v, frame)
    end
end

if ~isempty(saveto)
    close(v)
end

end

