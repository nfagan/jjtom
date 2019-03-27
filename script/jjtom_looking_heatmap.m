function out = jjtom_looking_heatmap(varargin)

defaults = jjtom.get_common_make_defaults();
defaults.not_files = {};
defaults.loop_runner = [];
defaults.normalizing_y_limits = [ -1.2, 1.2 ];
defaults.normalizing_x_limits = [ -1.2, 1.2 ];
defaults.normalizing_bin_size = 0.1;
defaults.start_event = '';
defaults.stop_event = '';
defaults.look_back = 0;
defaults.look_ahead = 0;

params = jjtom.parsestruct( defaults, varargin );
conf = params.config;

if ( isempty(params.loop_runner) )
  inputs = { 'edf/samples', 'recoded_events', 'labels', 'roi' };
  inputs = jjtom.get_datadir( inputs, conf );
  
  runner = shared_utils.pipeline.LoopedMakeRunner();
  
  runner.is_parallel = params.is_parallel;
  runner.input_directories = inputs;
  runner.filter_files_func = @(x) shared_utils.io.filter_files( x, params.files, params.not_files );
  runner.get_identifier_func = @(x, y) sprintf( '%s.mat', x.fileid );
  
else
  runner = params.loop_runner;
end

runner.convert_to_non_saving_with_output();

results = runner.run( @main, params );
outputs = [ results([results.success]).output ];

if ( isempty(outputs) )
  warning( 'No files were successfully processed.' );
  out = struct();
  return
end

out = struct();
out.hist = vertcat( outputs.hist );
out.labels = vertcat( fcat, outputs.labels );
out.x_edges = outputs(1).x_edges;
out.y_edges = outputs(1).y_edges;

end

function [norm_x, norm_y] = roi_normalize_position(roi, x, y)

w = roi(3) - roi(1);
h = roi(4) - roi(2);

norm_x = (x - roi(1)) / w;
norm_y = (y - roi(2)) / h;

end

function edges = get_edges(nl, bs)

edges = nl(1):bs:nl(2);

end

function [x_edges, y_edges] = get_xy_edges(params)

bs = params.normalizing_bin_size;

x_nl = params.normalizing_x_limits;
y_nl = params.normalizing_y_limits;

x_edges = get_edges( x_nl, bs );
y_edges = get_edges( y_nl, bs );

end

function [start_time, stop_time] = get_start_stop_time(evt_file, params)

start_evt = params.start_event;
stop_evt = params.stop_event;
lb = params.look_back;
la = params.look_ahead;

[start_time, stop_time] = ...
  jjtom.get_start_stop_times_from_events_file( evt_file, start_evt, stop_evt, lb, la );

end

function [x, y, t] = keep_within_time(x, y, t, start, stop)

t_ind = t >= start & t < stop;

x = x(t_ind);
y = y(t_ind);
t = t(t_ind);

end

function roi = get_normalizing_roi(roi_file)

app_l = roi_file.rois.apparatusl;
app_r = roi_file.rois.apparatusr;

min_x = app_l(1);
max_x = app_r(3);

min_y = (app_l(2) + app_r(2)) / 2;
max_y = (app_l(4) + app_r(4)) / 2;

roi = [ min_x, min_y, max_x, max_y ];

end

function out = main(files, params)

labels_file = shared_utils.general.get( files, 'labels' );
samples_file = shared_utils.general.get( files, 'samples' );
roi_file = shared_utils.general.get( files, 'roi' );
events_file = shared_utils.general.get( files, 'recoded_events' );

[start_time, stop_time] = get_start_stop_time( events_file, params );

normalizing_roi = get_normalizing_roi( roi_file );
[x_edges, y_edges] = get_xy_edges( params );

[x, y, t] = keep_within_time( samples_file.x, samples_file.y, samples_file.t, start_time, stop_time );
[x, y] = roi_normalize_position( normalizing_roi, x, y );

norm_hist = zeros( numel(y_edges)-1, numel(x_edges)-1 );

for i = 1:numel(x_edges)-1
  for j = 1:numel(y_edges)-1
    min_x = x_edges(i);
    max_x = x_edges(i+1);
    min_y = y_edges(j);
    max_y = y_edges(j+1);
    
    norm_hist(j, i) = sum( x >= min_x & x <= max_x & y >= min_y & y <= max_y );
  end
end

out.hist = { norm_hist };
out.labels = fcat.from( labels_file.labels, labels_file.categories );
out.x_edges = x_edges(1:end-1);
out.y_edges = y_edges(1:end-1);

end