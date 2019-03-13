function jjtom_add_familiarization_trial_pulses_to_recoded_events(varargin)

defaults = jjtom.get_common_make_defaults();
defaults.ft1_trial_label = 'ft1-start';
defaults.ft2_trial_label = 'ft2-start';

params = jjtom.parsestruct( defaults, varargin );

ft1_trial_label = params.ft1_trial_label;
ft2_trial_label = params.ft2_trial_label;

% pulse number 3 -> familiarization trial 2 start
% except KrRe -> pulse 4

conf = params.config;

recoded_events_p = jjtom.get_datadir( 'recoded_events', conf );
edf_p = jjtom.get_datadir( 'edf', conf );

recoded_mats = shared_utils.io.findmat( recoded_events_p );

for i = 1:numel(recoded_mats)
  shared_utils.general.progress( i, numel(recoded_mats) );
  
  recoded_file = shared_utils.io.fload( recoded_mats{i} );
  file_id = recoded_file.fileid;
  file_name = sprintf( '%s.mat', file_id );
  
  edf_file = shared_utils.io.fload( fullfile(edf_p, file_name) );
  
  is_trial_label_ft1 = strcmp( recoded_file.key, ft1_trial_label );
  is_trial_label_ft2 = strcmp( recoded_file.key, ft2_trial_label );
  
  edf_events = get_sync_times( edf_file );
  
  if ( strcmpi(file_id, 'KrRe') )
    ft2_pulse_index = 4;
    ft1_pulse_index = 2;
  else
    ft2_pulse_index = 3;
    ft1_pulse_index = 1;
  end
  
  ft2_event_time = edf_events(ft2_pulse_index);
  ft1_event_time = edf_events(ft1_pulse_index);
  
  if ( any(is_trial_label_ft1) )
    recoded_file.events(is_trial_label_ft1) = ft1_event_time;
  else
    recoded_file.events(end+1) = ft1_event_time;
    recoded_file.key{end+1} = ft1_trial_label;
  end
  
  if ( any(is_trial_label_ft2) )
    recoded_file.events(is_trial_label_ft2) = ft2_event_time;
  else
    recoded_file.events(end+1) = ft2_event_time;
    recoded_file.key{end+1} = ft2_trial_label;
  end
  
  save( recoded_mats{i}, 'recoded_file' );
end

end

function sync_times = get_sync_times(edf_file)
sync_pulses = strcmp( edf_file.Events.Messages.info, 'sync' );
sync_times = edf_file.Events.Messages.time( sync_pulses );
end