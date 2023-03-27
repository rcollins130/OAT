function plot_track_closeup(ax, vid_cdata, vid_times, track, saveto)
%PLOT_TRACK_CLOSEUP Summary of this function goes here
%   Detailed explanation goes here

arguments
    ax
    vid_cdata
    vid_times
    track
    saveto = []
end

padding = [120,60];

if ~isempty(saveto)
    v = VideoWriter(saveto, 'MPEG-4');
    open(v)
end    


if isempty(ax)
    im = imshow(vid_cdata(1:padding(2),1:padding(1),:,1), ...
         'InitialMagnification',2000,'Interpolation',"bilinear");
    ax = im.Parent;
else
    im = imshow(vid_cdata(1:padding(2),1:padding(1),:,1), ...
        'Parent', ax, 'InitialMagnification',2000,'Interpolation',"bilinear");
end


for ii_f=1:size(track.frame_idxs,1)
    cent = track.centroids(ii_f,:);
    yidx = max(1,floor(cent(2)-padding(2)/2)):min(size(vid_cdata,1), cent(2)+padding(2)/2);
    xidx = max(1,floor(cent(1)-padding(1)/2)):min(size(vid_cdata,2), cent(1)+padding(1)/2);
    % TODO: pad cdata so we don't clip 
    im.CData = vid_cdata( yidx, xidx,  :,  track.frame_idxs(ii_f));
    title(string(vid_times(track.frame_idxs(ii_f))))
    
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

