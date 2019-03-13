function jjtom_experiment_replayer(target_file_id, varargin)

defaults = jjtom.get_common_make_defaults();
defaults.window_rect = [];
defaults.calibration_rect = [ -1e3, -1e3, 3e3, 3e3 ];
defaults.indicator_size = 10;
defaults.time_multiplier = 1;
defaults.start_offset = 0;
defaults.start_event = '';
defaults.roi_names = {};

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;

edf_p = jjtom.get_datadir( 'edf', conf );
roi_p = jjtom.get_datadir( 'roi', conf );
evt_p = jjtom.get_datadir( 'recoded_events', conf );

window = ptb.Window( params.window_rect );
open( window );

edf_files = shared_utils.io.findmat( edf_p );
edf_files = shared_utils.io.filter_files( edf_files, target_file_id );

if ( numel(edf_files) == 0 )
  error( 'No edf files matched "%s".', char(target_file_id) );
end

edf_file = shared_utils.io.fload( edf_files{1} );
roi_file = shared_utils.io.fload( fullfile(roi_p, jjtom.ext(edf_file.fileid, '.mat')) );
evt_file = shared_utils.io.fload( fullfile(evt_p, jjtom.ext(edf_file.fileid, '.mat')) );

data = ptb.Reference();
data.Value.roi_file = roi_file;
data.Value.evt_file = evt_file;
data.Value.edf_file = edf_file;
% data.Value.edf_file.calibration_rect = get_calibration_rect( edf_file );
data.Value.edf_file.calibration_rect = params.calibration_rect;
data.Value.edf_file.start_time = get_edf_start_time( edf_file, evt_file, params );
data.Value.window = window;
data.Value.eye_position_indicator = make_eye_position_indicator( params.indicator_size );
data.Value.time_multiplier = params.time_multiplier;
data.Value.roi_names = params.roi_names;

task = ptb.Task();
state = ptb.State();
state.Entry = @(st) next( st, state );
state.Loop = @(state) looper( state, data );

data.Value.TASK = task;

task.Duration = inf;
task.exit_on_key_down();
task.run( state );

end

function eye_dot = make_eye_position_indicator(sz)

eye_dot = ptb.stimuli.Oval();
eye_dot.Scale = [ sz, sz ];
eye_dot.FaceColor = set( ptb.Color(), [255, 0, 0] );

end

function cal_rect = get_calibration_rect(edf_file)

info = edf_file.Events.Messages.info;
is_coord_msg = cellfun( @(x) ~isempty(strfind(lower(x), 'gaze_coords')), info );

assert( nnz(is_coord_msg) == 1 );

gaze_coord_info = info{is_coord_msg};
gaze_coord_split = strsplit( gaze_coord_info, ' ' );

assert( numel(gaze_coord_split) == 5 );

cal_rect = str2double( gaze_coord_split(2:end) );

assert( ~any(isnan(cal_rect)) );

end

function t = get_edf_start_time(edf_file, evt_file, params)

if ( isempty(params.start_event) )
  start_t = edf_file.Samples.time(1);
else
  evt_ind = strcmp( evt_file.key, params.start_event );
  
  assert( nnz(evt_ind) == 1, 'No matching event: "s".', params.start_event );
  
  start_t = evt_file.events(evt_ind);
end

t = start_t + params.start_offset;

end

function draw_rois(window, roi_file, roi_names, cal_rect, window_rect)

if ( isempty(roi_names) )
  roi_names = fieldnames( roi_file.rois );
end

cal_w = cal_rect(3) - cal_rect(1);
cal_h = cal_rect(4) - cal_rect(2);

window_w = window_rect(3) - window_rect(1);
window_h = window_rect(4) - window_rect(2);

for i = 1:numel(roi_names)
  rect = roi_file.rois.(roi_names{i});
  
  frac_x0 = (rect(1) - cal_rect(1)) / cal_w;
  frac_x1 = (rect(3) - cal_rect(1)) / cal_w;
  frac_y0 = (rect(2) - cal_rect(2)) / cal_h;
  frac_y1 = (rect(4) - cal_rect(2)) / cal_h;
  
  x0 = frac_x0 * window_w + window_rect(1);
  x1 = frac_x1 * window_w + window_rect(1);
  y0 = frac_y0 * window_h + window_rect(2);
  y1 = frac_y1 * window_h + window_rect(2);
  
  Screen( 'FrameRect', window.WindowHandle, [255, 0, 0], [x0, y0, x1, y1] );
end

end

function draw_events(window, evt_file, current_edf_t, text_x, text_y)

[sorted_events, sorted_ind] = sort( evt_file.events );

closest = find( sorted_events > current_edf_t, 1 );

if ( isempty(closest) || closest < 2 )
  return
end

sorted_keys = evt_file.key(sorted_ind);
current_event_name = sorted_keys{closest-1};

Screen( 'DrawText', window.WindowHandle, current_event_name, text_x, text_y, [255, 0, 0] );

end

function looper(state, data)

edf_file = data.Value.edf_file;
roi_file = data.Value.roi_file;
evt_file = data.Value.evt_file;

edf_start = edf_file.start_time;
cal_rect = edf_file.calibration_rect;
eye_pos_indicator = data.Value.eye_position_indicator;
window = data.Value.window;
roi_names = data.Value.roi_names;

elapsed_task = elapsed( data.Value.TASK ) * data.Value.time_multiplier;
elapsed_edf = round( elapsed_task * 1e3 + edf_start );

is_edf_sample = edf_file.Samples.time == elapsed_edf;
curr_x = edf_file.Samples.posX(is_edf_sample);
curr_y = edf_file.Samples.posY(is_edf_sample);

frac_x = (curr_x - cal_rect(1)) / (cal_rect(3) - cal_rect(1));
frac_y = (curr_y - cal_rect(2)) / (cal_rect(4) - cal_rect(2));

window_rect = get( window.Rect );

new_x = frac_x * (window_rect(3) - window_rect(1)) + window_rect(1);
new_y = frac_y * (window_rect(4) - window_rect(2)) + window_rect(2);

eye_pos_indicator.Position = [ new_x, new_y ];

draw( eye_pos_indicator, window );
draw_rois( window, roi_file, roi_names, cal_rect, window_rect );
draw_events( window, evt_file, elapsed_edf, window_rect(1), window_rect(2) );

flip( window );

end