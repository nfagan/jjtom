function rects = get_box_rois()

app_consts = jjtom.get_apparatus_constants();
screen_consts = jjtom.get_screen_constants();

app_dists = jjtom.get_apparatus_distances();
screen_dists = jjtom.get_screen_distances();

box_width = app_consts.box_width_cm;
box_height = app_consts.box_height_cm;

eye_to_base = app_dists.apparatus_base_to_ground - screen_dists.eye_to_ground_cm;

z_far2eye = app_dists.eye_to_lbox_front_cm;

%
%   left
%

x_far2eye = app_dists.eye_to_lbox_left_cm;
y_far2eye = eye_to_base;

[lmin_x_px, lmax_y_px] = jjtom.project_xyz( x_far2eye, y_far2eye, z_far2eye, screen_consts, screen_dists );

x_far2eye = app_dists.eye_to_lbox_left_cm + box_width;
y_far2eye = eye_to_base + box_height;

[lmax_x_px, lmin_y_px] = jjtom.project_xyz( x_far2eye, y_far2eye, z_far2eye, screen_consts, screen_dists );

%
%   right
%
x_far2eye = app_dists.eye_to_rbox_left_cm;
y_far2eye = eye_to_base;

[rmin_x_px, rmax_y_px] = jjtom.project_xyz( x_far2eye, y_far2eye, z_far2eye, screen_consts, screen_dists );

x_far2eye = app_dists.eye_to_rbox_left_cm + box_width;
y_far2eye = eye_to_base + box_height;

[rmax_x_px, rmin_y_px] = jjtom.project_xyz( x_far2eye, y_far2eye, z_far2eye, screen_consts, screen_dists );

rects = struct();
rects.lbox = [ lmin_x_px, lmin_y_px, lmax_x_px, lmax_y_px ];
rects.rbox = [ rmin_x_px, rmin_y_px, rmax_x_px, rmax_y_px ];

end