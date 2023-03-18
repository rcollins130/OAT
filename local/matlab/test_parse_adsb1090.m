clear;
fname = 'data/adsb/20230317_145402.mp4.adsb';
rawdata = readlines(fname);

tracks = parse_adsb1090(rawdata);

home = [37.57429, -122.35051];

figure(1); clf; hold on
x_c = cos(0:pi/10:2*pi)/60;
y_c = sin(0:pi/10:2*pi)/60;
for r=10:10:100
    plot(r*x_c+home(2), r*y_c+home(1), 'g-')
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
for ii_t=1:length(tracks)
    if size(tracks(ii_t).pos,1) > 0
        id = tracks(ii_t).id;
        if isempty(id)
            id = sprintf("icao: %s", tracks(ii_t).icao);
        end
        t = plot3(tracks(ii_t).pos(:,2), tracks(ii_t).pos(:,1), tracks(ii_t).alt(:,1), '.-','DisplayName',id);
        tp = [tp, t];
        text(tracks(ii_t).pos(1,2), tracks(ii_t).pos(1,1), tracks(ii_t).alt(1,1), id)
        
        if max(tracks(ii_t).pos(:,1)) > max_lat
            max_lat=max(tracks(ii_t).pos(:,1));
        end
        if min(tracks(ii_t).pos(:,1)) < min_lat
            min_lat=min(tracks(ii_t).pos(:,1));
        end
        if max(tracks(ii_t).pos(:,2)) > max_lon
            max_lon=max(tracks(ii_t).pos(:,2));
        end
        if min(tracks(ii_t).pos(:,2)) < min_lon
            min_lon=max(tracks(ii_t).pos(:,2));
        end
    end
end
xlim([min_lon-1/2, max_lon+1/2])
ylim([min_lat-1/2, max_lat+1/2])
xlabel('lon')
ylabel('lat')
zlabel('alt, ft')
legend([co, ho, tp])
