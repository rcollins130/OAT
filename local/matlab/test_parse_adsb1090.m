
fname = 'data/adsb/20230320_203920.adsb';
rawdata = readlines(fname);

adsb_tracks = parse_adsb1090(rawdata);

home = [37.57429, -122.35051];

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
legend([co, ho, tp])

figure(12); clf
ii_ts = [5,11];
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
