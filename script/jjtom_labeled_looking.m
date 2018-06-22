tic;

conf = jjtom.config.load();

fix_p = jjtom.get_datadir( 'edf/events', conf );
lab_p = jjtom.get_datadir( 'labels', conf );

evt_mats = jjtom.get_datafiles( 'events', conf );

look_back = -2e3;
look_ahed = 5e3;

nfix = [];
fixlabs = fcat();

for i = 1:numel(evt_mats)
  evt_file = jjtom.fload( evt_mats{i} );
  fname = jjtom.ext( evt_file.fileid, '.mat' );
  lab_file = jjtom.fload( fullfile(lab_p, fname) );
  fix_file = jjtom.fload( fullfile(fix_p, fname) );
  
  evts = evt_file.events;
  
  evtlabs = fcat.from( evt_file.key, {'event'} );
  metalabs = fcat.from( lab_file.labels, lab_file.categories );
  
  append( fixlabs, join(evtlabs, metalabs) );
  
  fix_starts = fix_file.fixstart;
  fix_stops = fix_file.fixstop;
  fix_durs = fix_stops - fix_starts;
  
  for j = 1:numel(evts)
    evt = evts(j);
    
    start = evt + look_back;
    stop = evt + look_ahed;
    
    ib = fix_starts >= start & fix_starts <= stop;
    ib = ib & fix_durs >= 25;
    
    nfix = [ nfix; sum(ib) ];
    
%     start_ind = find( t == start );
%     stop_ind = find( t == stop );
%     
%     fixations = false( 1, numel(edf_file.Samples.posX) );
%     starts = arrayfun( @(x) find(t == x), edf_file.Events.Efix.start );
%     stops = arrayfun( @(x) find(t == x), edf_file.Events.Efix.end );
% 
%     for k = 1:numel(starts)
%       fixations(starts(k):stops(k)) = true;
%     end
% 
%     fixations = fixations(start_ind:stop_ind);
% 
%     % fix_starts = shared_utils.logical.find_starts( fixations(:)', 50 );
%     [fix_starts, fix_durs] = shared_utils.logical.find_all_starts( fixations(:)' );
%     ind = fix_durs >= 25;
% 
%     fix_starts = fix_starts(ind);
%     fix_stops = fix_starts + fix_durs(ind) - 1;    
  end  
end

toc;

%%

pl = plotlabeled();
pl.summary_func = @plotlabeled.nanmean;
pl.error_func = @plotlabeled.nansem;
pl.one_legend = true;
pl.x_tick_rotation = 0;
pl.mask = find( fixlabs, {'test-reach'} );

pl.bar( nfix, fixlabs, 'reach_direction', 'reach_type', {'monkey', 'event'} );