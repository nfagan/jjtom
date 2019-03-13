function out = jjtom_get_looking_probability_timecourse(varargin)

defaults = jjtom.get_common_make_defaults();
defaults.bin_width = 250;
defaults.look_back = -3000;
defaults.look_ahead = 3000;
defaults.loop_runner = [];
defaults.normalize_looking_duration = false;
defaults.normalize_per_roi = true;
defaults.proportional_fixation_looking_duration = false;
defaults.maximum_normalization_window = inf;
defaults.fixation_looking_duration_proportions_each = {};
defaults.separate_apparatus_and_face = false;
defaults.event_subdir = 'events';
defaults.recoded_normalization_event_name = 'ft1-start';
defaults.recoded_normalization_look_ahead = 5e3;
defaults.not_files = {};

params = jjtom.parsestruct( defaults, varargin );
conf = params.config;

if ( isempty(params.loop_runner) )
  inputs = { params.event_subdir, 'edf/samples', 'edf/events', 'roi', 'labels' };
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

labs = vertcat( fcat(), outputs.labels );
probs = vertcat( outputs.probabilities );
lookdur = vertcat( outputs.looking_duration );
fix_lookdur = vertcat( outputs.fix_looking_duration );

assert_ispair( probs, labs );

out = struct();
out.labels = labs;
out.probabilities = probs;
out.duration_timecourse = vertcat( outputs.duration_timecourse );
out.looking_duration = lookdur;
out.fix_looking_duration = fix_lookdur;
out.fix_proportions = vertcat( outputs.fix_proportions );
out.n_fix_proportions = vertcat( outputs.n_fix_proportions );
out.t = outputs(1).t;
out.params = params;

end

function p = get_directory_name(path)

if ( ispc() )
  pathsep = '\';
else
  pathsep = '/';
end

split_path = strsplit( path, pathsep );

if ( strcmp(split_path{end-1}, 'edf') && strcmp(split_path{end}, 'events') )
  p = strjoin( split_path(end-1:end), '/' );
else
  p = shared_utils.pipeline.LoopedMakeRunner.get_directory_name( path );
end

end

function out = main(files, params)

evt_file =  shared_utils.general.get( files, params.event_subdir );
lab_file =  shared_utils.general.get( files, 'labels' );
samp_file = shared_utils.general.get( files, 'samples' );
edf_event_file = shared_utils.general.get( files, 'edf/events' );
roi_file =  shared_utils.general.get( files, 'roi' );

metalabs = fcat.from( lab_file.labels, lab_file.categories );

bin_width = params.bin_width;
look_back = params.look_back;
look_ahead = params.look_ahead;
is_recoded_events = strcmp( params.event_subdir, 'recoded_events' );

bin_ts = look_back:bin_width:(look_ahead + bin_width);

evts = evt_file.events;

t = samp_file.t(:);
x = samp_file.x(:);
y = samp_file.y(:);

fix_x = edf_event_file.fix_x;
fix_y = edf_event_file.fix_y;
fix_start = edf_event_file.fix_start;
fix_stop = edf_event_file.fix_stop;
fix_durs = fix_stop - fix_start;

rois = struct2cell( roi_file.rois );
roi_names = fieldnames( roi_file.rois );

inds = combvec( 1:numel(evts), 1:numel(roi_names) );
n_combs = size( inds, 2 );

ibs = false( numel(rois), numel(x) );
ib_fixs = cell( numel(rois), 1 );

for i = 1:numel(rois)
  ibs(i, :) = jjtom.rectbounds( x, y, rois{i} );
  ib_fixs{i} = jjtom.rectbounds( fix_x, fix_y, rois{i} );
end

if ( params.separate_apparatus_and_face )
  ib_fixs = separate_apparatus_and_face( ib_fixs, roi_names );  
end

if ( params.normalize_looking_duration )  
  % Normalize to period after occulder down, but before reach
  if ( is_recoded_events )
    norm_name = params.recoded_normalization_event_name;
    od3 = evt_file.events( strcmp(evt_file.key, norm_name) );
    reach = od3 + params.recoded_normalization_look_ahead;
  else
    od3 = evt_file.events( strcmp(evt_file.key, 'od-3') );
    reach = evt_file.events( strcmp(evt_file.key, 'test-reach') );
  end
  
  start_norm = od3;
  end_norm = reach;
  
  if ( ~isinf(params.maximum_normalization_window) )
    end_norm = min( end_norm, od3 + params.maximum_normalization_window );
  end
end

tmp_labs = fcat();
tmp_prob = [];
tmp_lookdur = [];
tmp_fix_lookdur = [];
tmp_n_fix = [];
tmp_lookdur_timecourse = [];

for i = 1:n_combs
  evt_ind = inds(1, i);
  roi_ind = inds(2, i);
  
  if ( params.normalize_per_roi )
    norm_roi_ind = roi_ind;
  else
    norm_roi_ind = find( strcmp(roi_names, 'apparatus') );
    assert( ~isempty(norm_roi_ind), 'No apparatus normalization roi found.' );
  end

  roi_name = roi_names{roi_ind};

  evt = evts(evt_ind);
  evt_name = evt_file.key(evt_ind);

  cats = { 'event', 'roi' };
  labs = [ evt_name, roi_name ];

  evtlabs = setcat( addcat(fcat(), cats), cats, labs );
  jointlabs = join( evtlabs', metalabs );

  ib_pos = columnize( ibs(roi_ind, :) );
  ib_fix = ib_fixs{roi_ind};
  norm_ib_pos = columnize( ibs(norm_roi_ind, :) );

  binned_n = zeros( 1, numel(bin_ts)-1 );
  
  % Binned proportions
  for k = 1:numel(bin_ts)-1
    ib_t = t >= evt + bin_ts(k) & t <= evt + bin_ts(k+1);
    binned_n(k) = sum( ib_t & ib_pos ) / sum( ib_t ) * 100;
  end
  
  % Fixation duration
  is_ib_fixt = fix_start >= evt + look_back & fix_start <= evt + look_ahead;
  fix_lookdur = sum( fix_durs(is_ib_fixt(:) & ib_fix(:)) );
  
  is_ib_fullt = t >= evt + look_back & t <= evt + look_ahead;
  
  % Looking duration
  look_dur = nnz( ib_pos(is_ib_fullt) );
  
  if ( params.normalize_looking_duration )
    is_ib_normt = t >= start_norm & t <= end_norm;
    look_dur = look_dur / nnz( norm_ib_pos(is_ib_normt) );
  end
  
  if ( params.normalize_looking_duration )
    is_ib_norm_fixt = fix_start >= start_norm & fix_start <= end_norm;
    norm_fix_lookdur = sum( fix_durs(is_ib_norm_fixt(:) & ib_fix(:)) );
    
    if ( params.proportional_fixation_looking_duration )
      fix_lookdur = fix_lookdur / nnz( is_ib_fixt );
      norm_fix_lookdur = norm_fix_lookdur / nnz( is_ib_norm_fixt );
    end
    
    fix_lookdur = fix_lookdur / norm_fix_lookdur;
    fix_lookdur = ternary( isinf(fix_lookdur), nan, fix_lookdur );
  end
  
  % Binned fixation duration timeourse
  binned_dur = zeros( 1, numel(bin_ts)-1 );
  for k = 1:numel(bin_ts)-1
    ib_t = fix_start >= evt + bin_ts(k) & fix_start <= evt + bin_ts(k+1);
    is_ib_fix_time_course = ib_t(:) & ib_fix(:);
    
    binned_dur(k) = sum(fix_durs(is_ib_fix_time_course));
    
    if ( params.normalize_looking_duration )
      binned_dur(k) = binned_dur(k) / norm_fix_lookdur;
    end
  end
  
  n_fix = sum( is_ib_fixt(:) & ib_fix(:) );

  tmp_prob = [ tmp_prob; binned_n ];
  tmp_lookdur_timecourse = [ tmp_lookdur_timecourse; binned_dur ];
  tmp_lookdur = [ tmp_lookdur; look_dur ];
  tmp_fix_lookdur = [ tmp_fix_lookdur; fix_lookdur ];
  tmp_n_fix = [ tmp_n_fix; n_fix ];
  
  append( tmp_labs, jointlabs );
end

props_each = params.fixation_looking_duration_proportions_each;

out = struct();
out.labels = tmp_labs;
out.probabilities = tmp_prob;
out.duration_timecourse = tmp_lookdur_timecourse;
out.looking_duration = tmp_lookdur;
out.fix_looking_duration = tmp_fix_lookdur;
out.fix_proportions = get_fix_proportions( tmp_fix_lookdur, tmp_labs, props_each );
out.n_fix_proportions = get_fix_proportions( tmp_n_fix, tmp_labs, props_each );
out.t = bin_ts(1:end-1);

end

function out_fixdur = get_fix_proportions(fixdur, labs, props_each)

out_fixdur = nan( size(fixdur) );

I = findall( labs, setdiff(getcats(labs), 'roi') );

for i = 1:numel(I)
  total_fix_dur = sum( fixdur(find(labs, props_each, I{i})) );
  
  for j = 1:numel(props_each)
    is_current_prop = find( labs, props_each{j}, I{i} );
    current_fix_dur = fixdur(is_current_prop);
    out_fixdur(is_current_prop) = current_fix_dur / total_fix_dur;
  end
end

end

function ib_fixs = separate_apparatus_and_face(ib_fixs, roi_names)

apparatus_l = strcmp( roi_names, 'apparatusl' );
apparatus_r = strcmp( roi_names, 'apparatusr' );

face_l = strcmp( roi_names, 'facel' );
face_r = strcmp( roi_names, 'facer' );

assert( nnz(apparatus_l | apparatus_r | face_l | face_r) == 4 );

is_ib_face = ib_fixs{face_l} | ib_fixs{face_r};

% Remove fixations that overlap between face and apparatus
ib_fixs{apparatus_l}(is_ib_face) = false;
ib_fixs{apparatus_r}(is_ib_face) = false;

end