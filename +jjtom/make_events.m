function make_events(varargin)

defaults = jjtom.get_common_make_defaults();
defaults.event_map = jjtom.get_event_map();

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;
event_map = params.event_map;

osd = params.output_subdir;
isd = params.input_subdir;

events_p = jjtom.get_datadir( fullfile('events', osd), conf );
unified_p = jjtom.get_datadir( fullfile('unified', isd), conf );
edfs = jjtom.get_datafiles( fullfile('edf', isd), conf, '.mat', params.files );

n_events = shared_utils.general.n_keys( event_map );

for i = 1:numel(edfs)
  shared_utils.general.progress( i, numel(edfs), mfilename );
  
  edf_file = shared_utils.io.fload( edfs{i} );
  
  unified_filename = jjtom.ext( edf_file.fileid, '.mat' );
  unified_file = shared_utils.io.fload( fullfile(unified_p, unified_filename) );
  
  output_fname = fullfile( events_p, unified_filename );
  
  if ( jjtom.check_overwrite(output_fname, params.overwrite) ), continue; end
  
  if ( isfield(unified_file, 'event_indices') )
    event_indices = unified_file.event_indices;
    use_custom_indices = true;
  else
    event_indices = 1:n_events;
    use_custom_indices = false;
  end
  
  try
    evts = get_sync_times( edf_file, event_indices, n_events, use_custom_indices );
  catch err
    warning( err.message );
    continue;
  end
  
  evt_names = arrayfun( @(x) event_map(x), 1:n_events, 'un', false );
  
  events_file = struct();
  events_file.fileid = edf_file.fileid;
  events_file.events = evts(:);
  events_file.key = evt_names(:);
  
  shared_utils.io.require_dir( events_p );
  save( output_fname, 'events_file' );
end

end

function sync_times = get_sync_times(edf_file, event_indices, n_events, use_custom)
sync_pulses = strcmp( edf_file.Events.Messages.info, 'sync' );
sync_times = edf_file.Events.Messages.time( sync_pulses );

if ( ~use_custom )
  assert( numel(sync_times) == numel(event_indices), 'Expected %d events; %d were present' ...
    , numel(event_indices), numel(sync_times) );
else
  assert( numel(event_indices) == n_events, 'Expected %d event indices; got %d.' ...
    , n_events, numel(event_indices) );  
end

sync_times = sync_times(event_indices);
end