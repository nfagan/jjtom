function dists = get_apparatus_distances()

dists = struct();

dists.eye_to_lbox_left_cm = -29;
dists.eye_to_rbox_left_cm = 22.5;
dists.eye_to_lemon_left_cm = 0;

% dists.apparatus_base_to_ground = 72.5;
dists.apparatus_base_to_ground = 57.75;

dists.eye_to_lbox_front_cm = 72;
dists.eye_to_rbox_front_cm = 72;
dists.eye_to_lemon_front_cm = 76;

dists.eye_to_human_left_cm = 0;
dists.eye_to_human_front_cm = 100;

% dists.app_origin_to_lbox_left_cm = 0;
% dists.app_origin_to_lbox_bottom_cm = 0;
% dists.app_origin_to_lbox_front_cm = 10;
% 
% dists.app_origin_to_rbox_left_cm = 51.5;
% dists.app_origin_to_rbox_bottom_cm = 0;
% dists.app_origin_to_rbox_front_cm = 10;

dists.monitor_origin_to_app_origin_left_cm = -12;
dists.monitor_origin_to_app_origin_front_cm = 28.5;

%
% new
% 

dists.app_origin_to_lemon_left_cm = 27.5;
dists.app_origin_to_lemon_bottom_cm = 0;
dists.app_origin_to_lemon_front_cm = 10.5;

dists.app_origin_to_lbox_left_cm = 0;
dists.app_origin_to_lbox_bottom_cm = 0;
dists.app_origin_to_lbox_front_cm = 6.2;

dists.app_origin_to_rbox_left_cm = 51.5;
dists.app_origin_to_rbox_bottom_cm = 0;
dists.app_origin_to_rbox_front_cm = 6.2;


end