function dists = get_screen_distances()

dists = struct();
dists.eye_to_monitor_left_cm = -21;   % x
dists.eye_to_monitor_front_cm = 42;    % z
dists.monitor_top_to_ground_cm = 88;
dists.eye_to_ground_cm = 69.3;
dists.eye_to_monitor_top_cm = dists.monitor_top_to_ground_cm - dists.eye_to_ground_cm;

end