function [x_px, y_px] = project_xyz( x_far2eye, y_far2eye, z_far2eye, screen_consts, screen_dists )

monitor_width_cm = screen_consts.MONITOR_WIDTH_CM;
monitor_height_cm = screen_consts.MONITOR_HEIGHT_CM;
monitor_bezel_cm = screen_consts.MONITOR_BEZEL_CM;
monitor_width_px = screen_consts.MONITOR_WIDTH_PX;
monitor_height_px = screen_consts.MONITOR_HEIGHT_PX;

monitor_bezel_cm = 0;

eye_x_to_monitor = screen_dists.eye_to_monitor_left_cm + monitor_bezel_cm;
eye_y_to_monitor = screen_dists.eye_to_monitor_top_cm - monitor_bezel_cm;
eye_z_to_screen = screen_dists.eye_to_monitor_front_cm;

x_near = jjtom.project_in( eye_z_to_screen, z_far2eye, x_far2eye );
y_near = jjtom.project_in( eye_z_to_screen, z_far2eye, y_far2eye );

x_near_from_monitor = x_near - eye_x_to_monitor;
y_near_from_monitor = eye_y_to_monitor - y_near;  % y is inverted

x_frac = x_near_from_monitor / monitor_width_cm;
y_frac = y_near_from_monitor / monitor_height_cm;

x_px = monitor_width_px * x_frac;
y_px = monitor_height_px * y_frac;

end