conf = jjtom.config.load();

edf_p = jjtom.get_datadir( 'edf', conf );
lab_p = jjtom.get_datadir( 'labels', conf );

evt_mats = jjtom.get_datafiles( 'events', conf );

look_back = 0;
look_ahed = 5e3;

evt_mats = evt_mats(1);

for i = 1:numel(evt_mats)
  evt_file = jjtom.fload( evt_mats{i} );
  fname = jjtom.ext( evt_file.fileid, '.mat' );
  lab_file = jjtom.fload( fullfile(lab_p, fname) );
  edf_file = jjtom.fload( fullfile(edf_p, fname) );
  
  t = edf_file.Samples.time;
  
  evts = evt_file.events;
  
  for j = 1:numel(evts)
    evt = evts(j);
    
    start_ind = find( t == evt + look_back );
    stop_ind = find( t == evt + look_ahead );
    
    fixations = false( 1, numel(edf_file.Samples.posX) );
    starts = arrayfun( @(x) find(t == x), edf_file.Events.Efix.start );
    stops = arrayfun( @(x) find(t == x), edf_file.Events.Efix.end );

    for k = 1:numel(starts)
      fixations(starts(k):stops(k)) = true;
    end

    fixations = fixations(start_ind:stop_ind);

    % fix_starts = shared_utils.logical.find_starts( fixations(:)', 50 );
    [fix_starts, fix_durs] = shared_utils.logical.find_all_starts( fixations(:)' );
    ind = fix_durs >= 25;

    fix_starts = fix_starts(ind);
    fix_stops = fix_starts + fix_durs(ind) - 1;    
  end  
end