function roi = get_roi(app_dists, screen_consts, screen_dists, xd, yd, zd, w, h)

%   distance between eye and apparatus origin
eye_to_base = app_dists.apparatus_base_to_ground - screen_dists.eye_to_ground_cm;

% 	distance between monitor front and apparatus
z_screen_to_base = app_dists.monitor_origin_to_app_origin_front_cm;

%   distance between monitor left-edge and apparatus left-edge
x_screen_to_base = app_dists.monitor_origin_to_app_origin_left_cm;

%
% min
%

z2eye = z_screen_to_base + screen_dists.eye_to_monitor_front_cm + zd;
x2eye = screen_dists.eye_to_monitor_left_cm + x_screen_to_base + xd;
y2eye = eye_to_base + yd;

[min_x_px, max_y_px] = jjtom.project_xyz( x2eye, y2eye, z2eye ...
  , screen_consts, screen_dists );

%
% max
%

x2eye = x2eye + w;
y2eye = y2eye + h;

[max_x_px, min_y_px] = jjtom.project_xyz( x2eye, y2eye, z2eye ...
  , screen_consts, screen_dists );

roi = [ min_x_px, min_y_px, max_x_px, max_y_px ];

end