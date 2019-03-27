function out = jjtom_interval_look_counts_sequence(varargin)

defaults = jjtom.get_common_make_defaults();
defaults.event_subdir = 'recoded_events';
defaults.not_files = {};
defaults.loop_runner = [];
defaults.start_event = '';
defaults.stop_event = '';
defaults.look_back = 0;
defaults.look_ahead = 0;
defaults.separate_apparatus_and_face = true;
defaults.pad_face_y = 0;

params = jjtom.parsestruct( defaults, varargin );
conf = params.config;

if ( isempty(params.loop_runner) )
  inputs = { params.event_subdir, 'edf/events', 'roi', 'labels' };
  inputs = jjtom.get_datadir( inputs, conf );
  
  runner = shared_utils.pipeline.LoopedMakeRunner();
  
  runner.is_parallel =              params.is_parallel;
  runner.input_directories =        inputs;
  runner.filter_files_func =        @(x) shared_utils.io.filter_files( x, params.files, params.not_files );
  runner.get_identifier_func =      @(x, y) sprintf( '%s.mat', x.fileid );
  runner.get_directory_name_func =  @get_directory_name;
  
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
out.labels = vertcat( fcat, outputs.labels );
out.fixation_counts = vertcat( outputs.fixation_counts );
out.roi_sequence = vertcat( fcat, outputs.roi_sequence );

out.params = params;

end

function [start_time, stop_time] = get_start_stop_time(evt_file, params)

start_evt = params.start_event;
stop_evt = params.stop_event;
lb = params.look_back;
la = params.look_ahead;

[start_time, stop_time] = ...
  jjtom.get_start_stop_times_from_events_file( evt_file, start_evt, stop_evt, lb, la );

end

function roi_file = add_dependent_rois(roi_file, params)

roi_file.rois.middle_fruit = jjtom.get_extended_fruit_roi_from_boxes( roi_file );
% roi_file.rois.face = get_padded_face_roi_from_facelr( roi_file.rois, params );
roi_file.rois.face = get_middle_face_roi_from_facelr( roi_file.rois, params );
roi_file.rois.facel = jjtom.pad_roi( roi_file.rois.facel, 0, params.pad_face_y );
roi_file.rois.facel = jjtom.pad_roi( roi_file.rois.facer, 0, params.pad_face_y );

end

function face_roi = get_middle_face_roi_from_facelr(rois, params)

face_roi = jjtom.get_middle_face_roi_from_facelr( rois.facel, rois.facer );
face_roi = jjtom.pad_roi( face_roi, 0, params.pad_face_y );

end

function face_roi = get_padded_face_roi_from_facelr(rois, params)

facel = rois.facel;
facer = rois.facer;

min_x = facel(1);
max_x = facer(3);

min_y = facer(2);
max_y = facer(4);

h = max_y - min_y;

half_h = h / 2;

min_y = min_y - half_h * params.pad_face_y;
max_y = max_y + half_h * params.pad_face_y;

face_roi = [ min_x, min_y, max_x, max_y ];

end

function out = main(files, params)

evt_file = shared_utils.general.get( files, params.event_subdir );
lab_file = shared_utils.general.get( files, 'labels' );
edf_event_file = shared_utils.general.get( files, 'edf/events' );
roi_file = add_dependent_rois( shared_utils.general.get(files, 'roi'), params );

[start_event_time, stop_event_time] = get_start_stop_time( evt_file, params );

roi_names = fieldnames( roi_file.rois );

ib_fixs = jjtom.is_inbounds_fixation_with_time( edf_event_file, roi_file ...
  , start_event_time, stop_event_time );

if ( params.separate_apparatus_and_face )
  ib_fixs = jjtom.separate_apparatus_and_face_fixations( ib_fixs, roi_names );
end

metalabs = fcat.from( lab_file.labels, lab_file.categories );
repmat( metalabs, numel(roi_names) );

addsetcat( metalabs, 'roi', roi_names );
addsetcat( metalabs, 'start-event', sprintf('start-%s', params.start_event) );
addsetcat( metalabs, 'stop-event', sprintf('stop-%s', params.stop_event) );

fix_counts = nan( numel(roi_names), 1 );

for i = 1:numel(roi_names)
  fix_counts(i) = sum( ib_fixs{i} );  
end

roi_sequence = get_roi_sequence( ib_fixs, edf_event_file.fix_start, metalabs' );

out = struct();
out.fixation_counts = fix_counts;
out.labels = metalabs;
out.roi_sequence = roi_sequence;

end

function roi_sequence = get_roi_sequence(ib_fixs, start_times, labels)

assert( numel(ib_fixs) == rows(labels) );

event_times = [];
roi_inds = [];

for i = 1:numel(ib_fixs)
  event_inds_this_roi = find( ib_fixs{i} );
  
  event_times = [ event_times; columnize(start_times(event_inds_this_roi)) ];
  roi_inds = [ roi_inds; repmat(i, numel(event_inds_this_roi), 1) ];
end

[~, sorted_I] = sort( event_times );
sorted_roi_inds = roi_inds(sorted_I);

roi_sequence = labels(sorted_roi_inds);

end

function p = get_directory_name(path)

split_path = strsplit( path, filesep() );

if ( strcmp(split_path{end-1}, 'edf') && strcmp(split_path{end}, 'events') )
  p = strjoin( split_path(end-1:end), '/' );
else
  p = shared_utils.pipeline.LoopedMakeRunner.get_directory_name( path );
end

end