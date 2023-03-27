function immov(A, vid_times, tdim, saveto)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

arguments
    A
    vid_times = []
    tdim = []
    saveto = []
end

if isempty(tdim)
    tdim = ndims(A);
end

if ~isempty(saveto)
    v = VideoWriter(saveto, 'MPEG-4');
    open(v)
end

gcf; clf;
C = repmat({':'},1,ndims(A));
C{tdim} = 1;
img = imshow(A(C{:}));
for ii_f=1:size(A,tdim)
    C = repmat({':'},1,ndims(A));
    C{tdim} = ii_f;
    img.set('CData', A(C{:}));
    if isempty(vid_times)
        title(sprintf("%d",ii_f));
    else
        title(strcat(sprintf("%d: ", ii_f), string(vid_times(ii_f))))
    end
    
    if ~isempty(saveto)
        frame = getframe(gcf);
        writeVideo(v, frame)
    end

    % if isempty(vid_times)
        pause(0.01)
    % else
    %     if ii_f<size(A,tdim)
    %         pa = vid_times(ii_f+1)-vid_times(ii_f);
    %         pa = seconds(pa);
    %         pause(pa)
    %     end
    % end
end

if ~isempty(saveto)
    close(v)
end
end

