function make_events(varargin)

defaults = jjtom.get_common_make_defaults();
defaults.event_map = jjtom.get_event_map();

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;
event_map = params.event_map;

osd = params.output_subdir;
isd = params.input_subdir;

events_p = jjtom.get_datadir( fullfile('events', osd), conf );
edfs = jjtom.get_datafiles( fullfile('edf', isd), conf, '.mat', params.files );

for i = 1:numel(edfs)
  shared_utils.general.progress( i, numel(edfs), mfilename );
  
  edf_file = shared_utils.io.fload( edfs{i} );
  
  output_fname = fullfile( events_p, jjtom.ext(edf_file.fileid, '.mat') );
  
  if ( jjtom.check_overwrite(output_fname, params.overwrite) ), continue; end
  
  try
    evts = get_sync_times( edf_file, 6 );
  catch err
    warning( err.message );
    continue;
  end
  
  evt_names = arrayfun( @(x) event_map(x), 1:numel(evts), 'un', false );
  
  events_file = struct();
  events_file.fileid = edf_file.fileid;
  events_file.events = evts(:);
  events_file.key = evt_names(:);
  
  shared_utils.io.require_dir( events_p );
  save( output_fname, 'events_file' );
end

end

function sync_times = get_sync_times(edf_file, n_events)
sync_pulses = strcmp( edf_file.Events.Messages.info, 'sync' );
sync_times = edf_file.Events.Messages.time( sync_pulses );

assert( numel(sync_times) == n_events, 'Expected %d events; %d were present' ...
  , n_events, numel(sync_times) );
end