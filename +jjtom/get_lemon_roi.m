function roi = get_lemon_roi(screen_dists, screen_consts, app_dists, app_consts, padding)

eye_to_base = app_dists.apparatus_base_to_ground - screen_dists.eye_to_ground_cm;

z_screen_to_base = app_dists.monitor_origin_to_app_origin_front_cm;
x_screen_to_base = app_dists.monitor_origin_to_app_origin_left_cm;

x_origin_to_lemon = app_dists.app_origin_to_lemon_left_cm;
z_origin_to_lemon = app_dists.app_origin_to_lemon_front_cm;
y_origin_to_lemon = app_dists.app_origin_to_lemon_bottom_cm;

w = app_consts.lemon_width_cm;
h = app_consts.lemon_height_cm;

if ( nargin == 5)
  [x_origin_to_lemon, w] = jjtom.pad( x_origin_to_lemon, w, padding.x );
  [y_origin_to_lemon, h] = jjtom.pad( y_origin_to_lemon, h, padding.y );
end

%
% min
%

z2eye = z_screen_to_base + screen_dists.eye_to_monitor_front_cm + z_origin_to_lemon;
x2eye = screen_dists.eye_to_monitor_left_cm + x_screen_to_base + x_origin_to_lemon;
y2eye = eye_to_base + y_origin_to_lemon;

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