function rect = get_human_roi()

app_consts = jjtom.get_apparatus_constants();
screen_consts = jjtom.get_screen_constants();

app_dists = jjtom.get_apparatus_distances();
screen_dists = jjtom.get_screen_distances();

human_width = app_consts.human_width_cm;
human_height = app_consts.human_height_cm;

eye_to_base = app_dists.apparatus_base_to_ground - screen_dists.eye_to_ground_cm;

x_far2eye = app_dists.eye_to_human_left_cm - human_width;
y_far2eye = eye_to_base + human_height;
z_far2eye = app_dists.eye_to_human_front_cm;

[minx, maxy] = jjtom.project_xyz( x_far2eye, y_far2eye, z_far2eye, screen_consts, screen_dists );

x_far2eye = app_dists.eye_to_human_left_cm;
y_far2eye = eye_to_base + human_height + 5;

[maxx, miny] = jjtom.project_xyz( x_far2eye, y_far2eye, z_far2eye, screen_consts, screen_dists );

rect = [ minx, miny, maxx, maxy ];

end