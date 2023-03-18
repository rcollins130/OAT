

%fname = 'data/movie/20230317_145402.mp4';
% [vid_cdata, t, vidObj] = load_video( ...
%     fname, ...
%     [8,18], ...
%     [40, 1400; 325, 950],...%[200, 800; 500, 950], ...
%     1, ...
%     1 ...
%     );

% fname = 'data/movie/20230317_190123.mp4';
% [vid_cdata, t, vidObj] = load_video( ...
%     fname, ...
%     [8,15], ...
%     [40, 1400; 325, 950],...%[200, 800; 500, 950], ...
%     1, ...
%     1 ...
%     ); 

% fname = 'data/movie/20230317_190613.mp4';
% [vid_cdata, t, vidObj] = load_video( ...
%     fname, ...
%     [8,18], ...
%     [40, 1400; 325, 950],...%[200, 800; 500, 950], ...
%     1, ...
%     1 ...
%     ); 

% fname = 'data/movie/20230317_193236.mp4';
% [vid_cdata, t, vidObj] = load_video( ...
%     fname, ...
%     [8,18], ...
%     [40, 1400; 325, 950],...%[200, 800; 500, 950], ...
%     1, ...
%     1 ...
%     ); 

% fname = 'data/movie/20230317_135249.mp4';
% [vid_cdata, t, vidObj] = load_video( ...
%     fname, ...
%     [8,18], ...
%     [40, 1400; 325, 950],...%[200, 800; 500, 950], ...
%     1, ...
%     1 ...
%     ); 


fname = '/Users/robertcollins/Stanford/Stanford_Google_Drive/ME354/Final_Project/test_data/IMG_0459.MOV';
[vid_cdata, t, vidObj] = load_video( ...
    fname, ...
    [15,35], ...
    [40, 1400; 325, 950],...%[200, 800; 500, 950], ...
    2, ...
    2 ...
    ); 

ts = get_mp4_creation_time(fname);
frame_time = ts+t;
whos vid_cdata

%%
vid_background = median(vid_cdata,4);

vid_nbg = abs(vid_cdata - vid_background);
vid_nbg = vid_nbg - min(vid_nbg,[],'all');
vid_nbg = vid_nbg ./ max(vid_nbg, [], 'all');

%%
% get mean, std of each color channel
% [color_std, color_mean] = std(vid_nbg, 0,[1,2,4]);

% here we should be able to remove bad frames by looking at outliers in
% color

% threshold only data outside one std of color channel
% TODO: vectorize this, would be much faster?
% n_std = 8;
% c_masks = zeros(size(vid_nbg),"logical");
% for ii_c = 1:size(c_masks, 3)
%     c_masks(:,:,ii_c,:) = abs(vid_nbg(:,:,ii_c,:)-color_mean(ii_c)) > n_std*color_std(ii_c);
% end
% imshow(double(c_masks(:,:,:,200)))

% binarize each color channel separately
%   todo: does this actually make a difference vs b&w?
%   also, does the abs above mess with this? 
vid_cbin = zeros(size(vid_nbg),'logical');
for ii_c = 1:size(vid_cbin,3)
    vid_cbin(:,:,ii_c,:) = imbinarize(squeeze(vid_nbg(:,:,ii_c,:)));
end

% 
vid_cbin_allcolor = squeeze(all(vid_cbin,3));
vid_cbin_anycolor = squeeze(any(vid_cbin,3));

% vid_cbin_anytime = squeeze(any(vid_cbin,4));

vid_obin_d = imdilate(vid_cbin_anycolor, strel('sphere',3));
vid_obin_d_m = mean(vid_obin_d,3);

%vid_obin_d_mbin = imbinarize(vid_obin_d_m);
% should scale this based on length/time scale of image compared to jet
vid_obin_d_thold = vid_obin_d_m > 0.25;
% note allcolor biases towards white planes
% NOTE- This caused issues for planes near dusk
vid_bin = ~vid_obin_d_thold & vid_cbin_allcolor;

% close image, filling holes in middle
%   might be abele to skip hole filling
se = strel('disk',5);
vid_bin = imdilate(vid_bin, se);
vid_bin = imfill(vid_bin, 'holes');
vid_bin = imerode(vid_bin,se);

%%
% se1 = strel( ...
%         'disk', ...
%         5 ...
%         );
% se2 = strel( ...
%         'disk', ...
%         2 ...
%         );
% vid_binary = zeros(size(vid_nbg,[1,2,4]));
raw_regions = cell(size(vid_cdata,4),1);
max_area = 0;
figure(1)
for ii_frame = 1:size(vid_nbg, 4)
%     frame_nbgn = im2gray(vid_nbg(:,:,:,ii_frame));
% %     frame_bin = imbinarize(frame_nbgn,0.25);
%     frame_bin = all(c_masks(:,:,:,ii_frame),3);
%     if 0
%         frame_dia = imdilate(frame_bin,se1);
%         frame_fill = imfill(frame_dia,"holes");
%         frame_err = imerode(frame_fill,se1);
%         frame_cb = imclearborder(frame_err);
%     else
%         frame = imclose(frame_bin, strel('disk',1));
%         frame = imfill(frame,"holes");
%         frame = imopen(frame, strel('disk',1));
%         frame_cb = imclearborder(frame);
%     end


    %frame_op = imopen(frame_err,se2);
    %frame_cb = imclearborder(frame_op);
    
    %vid_binary(:,:,ii_frame) = frame_cb;

    CC = bwconncomp(vid_bin(:,:,ii_frame));
    %sub_edges = edge(vid_binary(:,:,ii_frame));
    sub_stats = regionprops(CC);
    raw_regions{ii_frame} = sub_stats;
    if size(sub_stats,1)>=1
        max_area = max(max_area, max([sub_stats.Area]));
    end
    figure(1)
    subplot(2,1,1)
    imshow(vid_cdata(:,:,:,ii_frame))
    title(string(frame_time(ii_frame)))
    
    for ii_reg=1:size(sub_stats,1)
        bb = sub_stats(ii_reg).BoundingBox;
        hold on
        plot( ...
            [bb(1),bb(1),bb(1)+bb(3),bb(1)+bb(3),bb(1)], ...
            [bb(2),bb(2)+bb(4),bb(2)+bb(4),bb(2),bb(2)],'r-')
        hold off
    end

    subplot(2,1,2)
    imshow(vid_bin(:,:,ii_frame))
    %imshow(vid_nbgn(:,:,:,ii_frame))

    %subplot(3,1,3)
    %imshow(frame_cb)

    pause(0.01)
    
%     figure(2)
%     subplot(6,1,1); imshow(frame_nbgn)
%     subplot(6,1,2); imshow(frame_bin)
%     subplot(6,1,3); imshow(frame_dia)
%     subplot(6,1,4); imshow(frame_fill)
%     subplot(6,1,5); imshow(frame_err)
%     subplot(6,1,6); imshow(frame_cb)
%         pause(0.01)
end

%% region filtering by area
% filter regions by scale of largest area
filt_regions = cell(size(raw_regions));
n_reg = zeros(size(raw_regions));
for ii_f = 1:size(raw_regions, 1)
    if size(raw_regions{ii_f},1)>0
        filt_idx = [raw_regions{ii_f}.Area] > max_area*0.10;
        filt_regions{ii_f} = raw_regions{ii_f}(filt_idx);
        n_reg(ii_f)=size(filt_regions{ii_f},1);
    end
end

% figure(1); clf;
% for ii_f = 1:size(vid_cdata,4)
%     imshow(vid_cdata(:,:,:,ii_f))
%     hold on
%     sub_stats = filt_reg{ii_f};
%     for ii_reg=1:size(sub_stats,1)
%         bb = sub_stats(ii_reg).BoundingBox;
%         plot( ...
%             [bb(1),bb(1),bb(1)+bb(3),bb(1)+bb(3),bb(1)], ...
%             [bb(2),bb(2)+bb(4),bb(2)+bb(4),bb(2),bb(2)],'r-')
%     end
%     hold off
%     pause(0.01)
% end

regions = filt_regions;

%% form tracks
% may want to add more information to the track struct?
%   currently it's just a lookup table, and can get info form the
%   frame/region indicies
% also, could preallocate?
tracks = struct('frame_idxs',[],'region_idxs',[],'times',[],'centroids',[],'bbs',[]);
next_tid = 1;
region_tracks = cell(size(regions,1),1);
% initialize first regions
region_tracks{1} = zeros(size(regions{1},1));

figure(2); clf;
background = imshow(vid_cdata(:,:,:,1));
hold on;
track_traces = {};
region_plots = {};

for ii_f = 2:size(regions,1)
    region_tracks{ii_f} = zeros(size(regions{ii_f},1));
    this_regions = regions{ii_f};
    last_regions = regions{ii_f-1};

    % for testing, plot regions
    background.CData = vid_cdata(:,:,:,ii_f);
    for p=1:size(region_plots,2)
        delete(region_plots{p})
    end
    region_plots = {};
    for ii_reg=1:size(this_regions,1)
        bb = this_regions(ii_reg).BoundingBox;
        nr = plot( ...
            [bb(1),bb(1),bb(1)+bb(3),bb(1)+bb(3),bb(1)], ...
            [bb(2),bb(2)+bb(4),bb(2)+bb(4),bb(2),bb(2)],'r-');
        nt = text(bb(1),bb(2),sprintf("%d",ii_reg),'Color','r','HorizontalAlignment','right');
        region_plots = [region_plots {nr, nt}];
    end
    for ii_reg=1:size(last_regions,1)
        bb = last_regions(ii_reg).BoundingBox;
        nr = plot( ...
            [bb(1),bb(1),bb(1)+bb(3),bb(1)+bb(3),bb(1)], ...
            [bb(2),bb(2)+bb(4),bb(2)+bb(4),bb(2),bb(2)],'g-');
        nt = text(bb(1),bb(2),sprintf("%d",ii_reg),'Color','g','HorizontalAlignment','right');
        region_plots = [region_plots {nr, nt}];
    end

    for ii_tr = 1:size(this_regions,1)
        for ii_lr = 1:size(last_regions,1)
            % test for overlap - break this out to function
            %   think deeper about how this works? 
            tr_cent = this_regions(ii_tr).Centroid;
            tr_bb = this_regions(ii_tr).BoundingBox;
            lr_cent = last_regions(ii_lr).Centroid;
            lr_bb = last_regions(ii_lr).BoundingBox;

            % a: bounding box overlap
            % left edge
%             lo = tr_bb(1) >= lr_bb(1) && tr_bb(1) <= lr_bb(1)+lr_bb(3);
%             % right edge
%             ro = tr_bb(1)+tr_bb(3) >= lr_bb(1) && tr_bb(1)+tr_bb(3) <= lr_bb(1)+lr_bb(3);
%             % bottom edge
%             bo = tr_bb(2) >= lr_bb(2) && tr_bb(2) <= lr_bb(2)+lr_bb(4);
%             % top edge
%             to = tr_bb(2)+tr_bb(4) >= lr_bb(2) && tr_bb(2)+tr_bb(4) <= lr_bb(2)+lr_bb(4);
%             
            overlap =  (...
                (tr_bb(1) <= lr_bb(1)+lr_bb(3)) && ... % this left <= last right
                (tr_bb(1)+tr_bb(3) >= lr_bb(1)) && ... % this right >= last left
                (tr_bb(2) <= lr_bb(2)+lr_bb(4)) && ...  % this bottom <= last top
                (tr_bb(2)+tr_bb(4) >= lr_bb(2)) ...    % this top >= last bottom
            );
                
            % b: centroid containment
            
            % todo: what to do if two tracks intersect on a bounding box?

            if overlap
                % check if last region is on a track
                tid = region_tracks{ii_f-1}(ii_lr);
                if tid==0
                    % this is a new track, assign last region to it
                    tid = next_tid; next_tid = tid+1;
                    region_tracks{ii_f-1}(ii_lr) = tid;
                    tracks(tid).frame_idxs = ii_f-1;
                    tracks(tid).region_idxs = ii_lr;
                    tracks(tid).times = frame_time(ii_f-1);
                    tracks(tid).centroids = lr_cent;
                    tracks(tid).bbs = lr_bb;
                    text(lr_cent(1),lr_cent(2),sprintf("%d",tid));
                    track_traces{tid} = plot(lr_cent(1),lr_cent(2));
                end
                % assign track to region
                region_tracks{ii_f}(ii_tr) = tid;
                tracks(tid).frame_idxs = [tracks(tid).frame_idxs; ii_f];
                tracks(tid).region_idxs = [tracks(tid).region_idxs; ii_tr];
                tracks(tid).times = [tracks(tid).times; frame_time(ii_f)];
                tracks(tid).centroids = [tracks(tid).centroids; tr_cent];
                tracks(tid).bbs = [tracks(tid).bbs; tr_bb];
                track_traces{tid}.XData = [track_traces{tid}.XData, tr_cent(1)];
                track_traces{tid}.YData = [track_traces{tid}.YData, tr_cent(2)];

                % todo: may want to do track processing here
            end

        end
    end
    drawnow();
end

% figure(1)
% imshow(vid_background)
% hold on
% for tid=1:size(tracks,2)
% plot(tracks(tid).centroids(:,1),tracks(tid).centroids(:,2));
% text(tracks(tid).centroids(1,1),tracks(tid).centroids(1,2),sprintf("%d",tid),'Color','k');
% end

%% 
% figure(3); hold on
% ii_t = 5;
% padding = [20,10];
% 
% for ii_f=1:size(tracks(ii_t).frame_idxs,1)
%     bb = tracks(ii_t).bbs(ii_f,:);
%     yidx = max(1,floor(bb(2)-padding(2))):min(size(vid_cdata,1), ceil(bb(2)+bb(4)+padding(2)));
%     xidx = max(1,floor(bb(1)-padding(1))):min(size(vid_cdata,2), ceil(bb(1)+bb(3)+padding(2)));
%     imshow(vid_cdata(...
%         yidx, ...
%         xidx, ...
%         :, ...
%         tracks(ii_t).frame_idxs(ii_f)...
%     ))
%     title(string(frame_time(ii_t)))
%     
%     pause(0.001)
% end

%%

ii_max = 1;
l_max = 0;
for ii_t=1:size(tracks,2)
    l = size(tracks(ii_t).frame_idxs,1);
    if l>l_max
        ii_max=ii_t;
        l_max=l;
    end
end

figure(3); clf;
ii_t = ii_max;
padding = [120,60];

for ii_f=1:size(tracks(ii_t).frame_idxs,1)
    cent = tracks(ii_t).centroids(ii_f,:);
    yidx = max(1,floor(cent(2)-padding(2)/2)):min(size(vid_cdata,1), cent(2)+padding(2)/2);
    xidx = max(1,floor(cent(1)-padding(1)/2)):min(size(vid_cdata,2), cent(1)+padding(1)/2);
    imshow(vid_cdata(...
        yidx, ...
        xidx, ...
        :, ...
        tracks(ii_t).frame_idxs(ii_f)...
    ), 'InitialMagnification',2000,'Interpolation',"bilinear")
    hold on;
    title(string(frame_time(tracks(ii_t).frame_idxs(ii_f))))
    
    if ii_f<size(tracks(ii_t).frame_idxs,1)
        pa = frame_time(tracks(ii_t).frame_idxs(ii_f+1))-frame_time(tracks(ii_t).frame_idxs(ii_f));
        pa = seconds(pa);
    end
    pause(pa)
end

%%
function ts = get_mp4_creation_time(fname)
    cmd = sprintf("ffprobe -v quiet %s -print_format csv -show_entries stream=index,codec_type:stream_tags=creation_time:format_tags=creation_time",fname);
    [~,raw] = system(cmd,"PATH","/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin");
    lines = split(raw,[newline,","]);
    ts = datetime(lines{4},'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSS''Z');
end