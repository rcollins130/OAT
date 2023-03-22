
fidx = '20230317_145402';
fname = sprintf('data/adsb/%s.adsb',fidx);
%rawdata = readlines(fname);
adsb_toi = 3;
adsb_tracks = parse_adsb1090(fname);

home = [37.57429, -122.35051];
ft2m = .3048;

figure(11); clf; hold on
x_c = cos(0:pi/10:2*pi)/60;
y_c = sin(0:pi/10:2*pi)/60;
for r=10:10:100
    plot(r*x_c+home(2), r*y_c+home(1), 'g-')
    text(home(2),r/60+home(1),sprintf("%d nm",r),'Color','g')
end

d = shaperead('/Users/robertcollins/Stanford/Stanford_Google_Drive/ME354/Final_Project/maps/ne_10m_bathymetry_all/ne_10m_bathymetry_L_0.shp');
d_idx = 17;
co = plot3(d(d_idx).X, d(d_idx).Y,zeros(size(d(d_idx).X)),'k','LineWidth',3,'DisplayName','Coastline');
ho = plot3(home(2),home(1), 0, 'r', 'Marker','pentagram','MarkerFaceColor','r','MarkerSize',10, 'DisplayName','Home');

max_lat = -100;
min_lat = 100;
max_lon = -200;
min_lon = 200;
tp = [];
for ii_t=1:length(adsb_tracks)
    if size(adsb_tracks(ii_t).pos,1) > 0
        id = adsb_tracks(ii_t).id;
        if isempty(id)
            id = sprintf("icao: %s", adsb_tracks(ii_t).icao);
        end
        t = plot3(adsb_tracks(ii_t).pos(:,2), adsb_tracks(ii_t).pos(:,1), adsb_tracks(ii_t).alt(:,1), '.-','DisplayName',id);
        tp = [tp, t];
        text(adsb_tracks(ii_t).pos(1,2), adsb_tracks(ii_t).pos(1,1), adsb_tracks(ii_t).alt(1,1), id)
        
        if max(adsb_tracks(ii_t).pos(:,1)) > max_lat
            max_lat=max(adsb_tracks(ii_t).pos(:,1));
        end
        if min(adsb_tracks(ii_t).pos(:,1)) < min_lat
            min_lat=min(adsb_tracks(ii_t).pos(:,1));
        end
        if max(adsb_tracks(ii_t).pos(:,2)) > max_lon
            max_lon=max(adsb_tracks(ii_t).pos(:,2));
        end
        if min(adsb_tracks(ii_t).pos(:,2)) < min_lon
            min_lon=max(adsb_tracks(ii_t).pos(:,2));
        end
    end
end
xlim([min_lon-1/2, max_lon+1/2])
ylim([min_lat-1/2, max_lat+1/2])
xlabel('lon')
ylabel('lat')
zlabel('alt, ft')
pbaspect([1,1,1/(deg2km(1)*1000*ft2m)])
saveas(gcf, sprintf("media/%s_adsb_global.png",fidx))

% os =[0.5,0.5];
% xlim([home(2)-os(2), home(2)+os(2)])
% ylim([home(1)-os(1), home(1)+os(1)])
% pbaspect([1,1,0.25])
% legend([co, ho, tp])
% view([-45, 30])
% % ft/deg = km/deg * m/km * ft/m
% 
% v = VideoWriter(sprintf("media/%s_adsb_local.mp4", fidx),'MPEG-4');
% loops = 1;
% min_az = -45;
% max_az = 180;
% step=1;
% azs = repmat([min_az:step:max_az, max_az:-step:min_az],1, loops);
% open(v);
% for az=azs
%     view([az, 15])
%     frame = getframe(gcf);
%     writeVideo(v,frame)
% end
% 
% close(v);

figure(12); clf
ii_ts = [adsb_toi];
for ii_t = ii_ts
subplot(3,1,1); hold on
plot(adsb_tracks(ii_t).alt_t, adsb_tracks(ii_t).alt(:,1),"DisplayName",sprintf("%s // icao %s",adsb_tracks(ii_t).id, adsb_tracks(ii_t).icao))

subplot(3,1,2); hold on
plot(adsb_tracks(ii_t).pos_t, adsb_tracks(ii_t).pos(:,1))

subplot(3,1,3); hold on
plot(adsb_tracks(ii_t).pos_t, adsb_tracks(ii_t).pos(:,2))
end

subplot(3,1,1)
legend('Location','northeast')
ylabel('Alt, ft')

subplot(3,1,2)
ylabel('Lat')

subplot(3,1,3)
ylabel('Lon')

adsb_toi_t = adsb_tracks(adsb_toi).pos_t;
adsb_toi_az = zeros(size(adsb_toi_t));
adsb_toi_arclen = zeros(size(adsb_toi_t));

wgs84 = wgs84Ellipsoid("meter");
for ii = 1:size(adsb_toi_t,1)
[adsb_toi_arclen(ii), adsb_toi_az(ii)] = distance( ...
    home,adsb_tracks(adsb_toi).pos(ii,:),wgs84 ...
);
end
