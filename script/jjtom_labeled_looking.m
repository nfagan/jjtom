tic;

conf = jjtom.config.load();

fix_p = jjtom.get_datadir( 'edf/events', conf );
roi_p = jjtom.get_datadir( 'roi', conf );
lab_p = jjtom.get_datadir( 'labels', conf );

evt_mats = jjtom.get_datafiles( 'events', conf );

min_dur = 25;
look_back = -3e3;
look_ahead = 0e3;

nfix = [];
fixdur = [];

nfixlabs = fcat();
durlabs = fcat();
firstlabs = fcat();

for i = 1:numel(evt_mats)
  evt_file = jjtom.fload( evt_mats{i} );
  fname = jjtom.ext( evt_file.fileid, '.mat' );
  lab_file = jjtom.fload( fullfile(lab_p, fname) );
  fix_file = jjtom.fload( fullfile(fix_p, fname) );
  roi_file = jjtom.fload( fullfile(roi_p, fname) );
  
  metalabs = fcat.from( lab_file.labels, lab_file.categories );
  
  evts = evt_file.events;
  
  fix_x = fix_file.fix_x;
  fix_y = fix_file.fix_y;
  fix_starts = fix_file.fix_start;
  fix_stops = fix_file.fix_stop;
  fix_durs = fix_stops - fix_starts;
  
  rois = struct2cell( roi_file.rois );
  roi_names = fieldnames( roi_file.rois );
  
  inds = combvec( 1:numel(evts), 1:numel(roi_names) );
  n_combs = size( inds, 2 );
  
  for j = 1:n_combs
    evt_ind = inds(1, j);
    roi_ind = inds(2, j);
    
    roi = rois{roi_ind};
    roi_name = roi_names{roi_ind};
    
    evt = evts(evt_ind);
    evt_name = evt_file.key(evt_ind);
    
    cats = { 'event', 'roi' };
    labs = [ evt_name, roi_name ];
    
    evtlabs = setcat( addcat(fcat(), cats), cats, [evt_name, roi_name] );
    jointlabs = join( evtlabs, metalabs );
    
    start = evt + look_back;
    stop = evt + look_ahead;
    
    ib_t = fix_starts >= start & fix_starts <= stop & fix_durs >= min_dur;
    ib_pos = jjtom.rectbounds( fix_x, fix_y, roi );
    
    ib = ib_t & ib_pos;
    
    nfix = [ nfix; sum(ib) ];
    fixdur = [ fixdur; reshape(fix_durs(ib), [], 1) ];
    
    append( nfixlabs, jointlabs );
    append( durlabs, repmat(jointlabs', sum(ib)) );   
  end  
  
  %   
  %   looks to which roi first
  %   
  roi1_name = 'boxl';
  roi2_name = 'boxr';
  neither_name = 'neither-first';
  roi1 = rois{ strcmp(roi_names, roi1_name) };
  roi2 = rois{ strcmp(roi_names, roi2_name) };
  first_names = cell( size(evts) );
  
  for j = 1:numel(evts)
    start = evts(j) + look_back;
    stop = evts(j) + look_ahead;
    
    ib = fix_starts >= start & fix_starts <= stop & fix_durs >= min_dur;
    ib1 = ib & jjtom.rectbounds( fix_x, fix_y, roi1 );
    ib2 = ib & jjtom.rectbounds( fix_x, fix_y, roi2 );
    
    first1 = find( ib1, 1, 'first' );
    first2 = find( ib2, 1, 'first' );
    
    emp1 = isempty( first1 );
    emp2 = isempty( first2 );
    
    if ( emp1 && emp2 )
      first_names{j} = neither_name;
    elseif ( emp1 )
      first_names{j} = roi2_name;
    elseif ( emp2 )
      first_names{j} = roi1_name;
    else
      if ( first1 < first2 )
        first_names{j} = roi1_name;
      elseif ( first2 < first1 )
        first_names{j} = roi2_name;
      else
        first_names{j} = neither_name;
      end
    end    
  end
  
  evtlabs = fcat.with( {'event', 'roi'} );
  setcat( evtlabs, {'event', 'roi'}, [ evt_file.key(:), first_names(:)] );  
  append( firstlabs, join(evtlabs, metalabs) );
  
end

toc;

%%  first look

pl = plotlabeled();
pl.summary_func = @(x) sum(x, 1);
pl.error_func = @plotlabeled.nansem;
pl.one_legend = true;
pl.x_tick_rotation = 0;
pl.shape = [ 4, 2 ];
pl.mask = find( firstlabs, {'test-reach'} );

dummy_data = ones( length(firstlabs), 1 );

axs = pl.bar( dummy_data, firstlabs, 'roi', 'reach_direction', {'monkey', 'event'} );
ylabel( axs(1), 'First look' );


%%  nfix

pl = plotlabeled();
pl.summary_func = @plotlabeled.nanmean;
pl.error_func = @plotlabeled.nansem;
pl.one_legend = true;
pl.x_tick_rotation = 0;
pl.shape = [4, 2];
pl.fig = figure(1);
pl.mask = find( nfixlabs, {'test-reach', 'boxl', 'boxr'} );

replace( nfixlabs, 'left', 'reach-type-left' );
replace( nfixlabs, 'right', 'reach-type-right' );

axs = pl.bar( nfix, nfixlabs, 'reach_direction', 'roi', {'monkey', 'event', 'reach_type'} );
ylabel( axs(1), 'N Fixations' );

%%  fix dur

pl = plotlabeled();
pl.summary_func = @plotlabeled.nanmean;
pl.error_func = @plotlabeled.nansem;
pl.one_legend = true;
pl.x_tick_rotation = 0;
pl.mask = find( durlabs, {'test-reach', 'od-3', 'apparatus'} );

axs = pl.bar( fixdur, durlabs, 'reach_direction', 'reach_type', {'event', 'roi'} );
ylabel( axs(1), 'Fix duration' );