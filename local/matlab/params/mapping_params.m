
function mapping = mapping_params(record)
% Geographic parameters
%   Note these are grabbed from Google Earth KML files, which use lon/lat coords
mapping.camera_geo_pos = [-122.3504544996347,37.574338523816];
mapping.pole1_geo_pos = [-122.3501734874045,37.57435293999236];
mapping.pole2_geo_pos = [-122.3499545470562,37.57456814522148];
mapping.pole3_geo_pos = [-122.3496253973898,37.57490551692827];
mapping.tree1_geo_pos = [-122.349706660672,37.57493462300901];
mapping.tree2_geo_pos = [];
mapping.tree3_geo_pos = [];
mapping.crane_geo_pos = [-122.3458564048449,37.57818930045685];

mapping.geo_domain_coords = [
    -122.3629652408847,37.60516752250595;
    -122.3038089987941,37.5782002668758;
    -122.2893495574569,37.6046904856423;
    -122.3550536749479,37.61998451901371;
    -122.3629652408847,37.60516752250595;
];
mapping.geo_domain_poly = geopolyshape( ...
    mapping.geo_domain_coords(:,2), ...
    mapping.geo_domain_coords(:,1)...
);

mapping.geo_alt_lims_ft = [
    0, 6000
];


mapping.pole1_frame_pos = [];
mapping.pole2_frame_pos = [];
mapping.pole3_frame_pos = [];
mapping.tree1_frame_pos = [];
mapping.tree2_frame_pos = [];
mapping.tree3_frame_pos = [];
mapping.crane_frame_pos = [];

if record == "20230317_145402"
    mapping.pole2_frame_pos = [1362 774];
    mapping.pole3_frame_pos = [516 872];
    mapping.tree1_frame_pos = [207 372];
else
    
end

end