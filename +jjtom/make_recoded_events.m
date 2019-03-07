function results = make_recoded_events(varargin)

defaults = jjtom.get_common_make_defaults();
defaults.time0_recoded_event_name = 'sound 5';
defaults.get_time0_from_edf_file_func = @get_time0_from_edf_file;

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;

xls_events = jjtom.load_xls_event_times( 'config', conf );

runner = shared_utils.pipeline.LoopedMakeRunner();

runner.input_directories = jjtom.get_datadir( 'edf', conf );
runner.output_directory = jjtom.get_datadir( 'recoded_events', conf );
runner.get_identifier_func = @(varargin) varargin{1}.fileid;
runner.is_parallel = params.is_parallel;
runner.save = params.save;
runner.overwrite = params.overwrite;

if ( params.skip_existing )
  runner.set_skip_existing_files();
end

results = runner.run( @recoded_main, xls_events, params );

end

function t = get_time0_from_edf_file(edf_file)

sync_pulses = strcmp( edf_file.Events.Messages.info, 'sync' );
sync_times = edf_file.Events.Messages.time( sync_pulses );

t = sync_times(end-1);

end

function recoded_file = recoded_main(files, xls_events, params)

edf_file = shared_utils.general.get( files, 'edf' );

file_id = edf_file.fileid;

is_matching_file_id = strcmpi( xls_events.file_ids, file_id );
assert( nnz(is_matching_file_id) == 1 ...
  , '0 or more than 1 matching event for: "%s".', file_id );

recoded_times = xls_events.event_times(is_matching_file_id, :);

time0_recoded_event_name = params.time0_recoded_event_name;
time0_recoded_event_index = strcmp( xls_events.event_key, time0_recoded_event_name );
assert( nnz(time0_recoded_event_index) == 1 ...
  , '0 or more than 1 time 0 recoded event for "%s".', time0_recoded_event_name ); 

time0_recoded = recoded_times(time0_recoded_event_index);

assert( ~isnan(time0_recoded), 'Time 0 was NaN.' );

edf_time0 = params.get_time0_from_edf_file_func( edf_file );

recoded_times_in_edf_time = nan( size(recoded_times) );

for i = 1:numel(recoded_times)
  target_t = recoded_times(i);
  
  if ( isnan(target_t) )
    continue; 
  end
  
  recoded_offset_seconds = target_t - time0_recoded;
  offset_ms = round( recoded_offset_seconds * 1e3 );
  
  recoded_times_in_edf_time(i) = edf_time0 + offset_ms;
end

recoded_file = struct();
recoded_file.fileid = file_id;
recoded_file.events = recoded_times_in_edf_time(:);
recoded_file.key = xls_events.event_key(:);
recoded_file.params = params;
recoded_file.is_recoded = true;

end