function ib_fixs = is_inbounds_fixation_with_time(edf_event_file, roi_file, start_time, stop_time)

fix_starts = edf_event_file.fix_start;
fix_stops = edf_event_file.fix_stop;

is_in_time_bounds = fix_starts >= start_time & fix_stops <= stop_time;

roi_names = fieldnames( roi_file.rois );
rois = cellfun( @(x) roi_file.rois.(x), roi_names, 'un', 0 );

ib_fixs = jjtom.is_inbounds_fixation( edf_event_file.fix_x, edf_event_file.fix_y, rois );
ib_fixs = cellfun( @(x) x & is_in_time_bounds, ib_fixs, 'un', 0 );

end