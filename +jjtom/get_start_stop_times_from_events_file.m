function [start_time, stop_time] = ...
  get_start_stop_times_from_events_file(evt_file, start_event, stop_event, look_back, look_ahead)

start_event_ind = strcmp( evt_file.key, start_event );
stop_event_ind = strcmp( evt_file.key, stop_event );

assert( any(start_event_ind) && any(stop_event_ind) ...
  , 'No events matched "%s" or "%s".', start_event, stop_event );

start_time = evt_file.events(start_event_ind) + look_back;
stop_time = evt_file.events(stop_event_ind) + look_ahead;

end