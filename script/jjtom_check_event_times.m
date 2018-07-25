function jjtom_check_event_times()

conf = jjtom.config.load();

evt_mats = jjtom.get_datafiles( 'events', conf );

lab_p = jjtom.get_datadir( 'labels', conf );

diffs = [];
labs = fcat();

for i = 1:numel(evt_mats)
  evt_file = jjtom.fload( evt_mats{i} );
  fname = jjtom.ext( evt_file.fileid, '.mat' );
  
  lab_file = jjtom.fload( fullfile(lab_p, fname) );
  
  od3 = strcmp( evt_file.key, 'od-3' );
  reach = strcmp( evt_file.key, 'test-reach' );
  
  assert( sum(od3 | reach) == 2, 'Missing events' );
  
  tmp_diff = evt_file.events(reach) - evt_file.events(od3);  
  
  tmp_labs = fcat.from( lab_file.labels, lab_file.categories );
  
  append( labs, tmp_labs );
  
  diffs = [ diffs; tmp_diff ];
end