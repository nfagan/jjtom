conf = jjtom.config.load();

base_plotp = fullfile( conf.PATHS.data_root, 'plots' );

fix_p = jjtom.get_datadir( 'edf/events', conf );
roi_p = jjtom.get_datadir( 'roi', conf );
lab_p = jjtom.get_datadir( 'labels', conf );

evt_mats = jjtom.get_datafiles( 'events', conf );

min_dur = 25;
look_back = -2e3;
look_ahead = 10e3;

nfixs = [];
durs = [];
durlabs = fcat();

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
    
    ib_t = fix_starts >= evt + look_back & fix_starts <= evt + look_ahead;
    ib_pos = jjtom.rectbounds( fix_x, fix_y, roi );
    
    ib = ib_t & ib_pos;
    
    nfixs = [ nfixs; sum(ib) ];
    durs = [ durs; sum(fix_durs(ib)) ];
    
    append( durlabs, jointlabs );
  end    
end


%%
tic;

targcat = 'target';

pltlabs = durlabs';

all_apples = jjtom.get_apple_indices( pltlabs );
all_hands = jjtom.get_hand_indices( pltlabs );

replace( pltlabs, 'left', 'reach-to-left' );
replace( pltlabs, 'right', 'reach-to-right' );
replace( pltlabs, 'apparatusl', 'apparatus-left' );
replace( pltlabs, 'apparatusr', 'apparatus-right' );
replace( pltlabs, 'boxl', 'box-left' );
replace( pltlabs, 'boxr', 'box-right' );

replabs = addcat( pltlabs', targcat );

applelabs = setcat( replabs', targcat, 'apple', all_apples );
handlabs = setcat( replabs', targcat, 'hand', all_hands );
replabs = append( applelabs', handlabs );

repdur = repmat( durs, 2, 1 );
repfix = repmat( nfixs, 2, 1 );

alldata = [ repdur; repfix ];

repset( addcat(replabs, 'measure'), 'measure', {'duration', 'nfix'} );
prune( replabs );

toc;

%%

do_save = false;

meas_type = 'nfix';
prefix = 'bars';

replace( replabs, {'box-left', 'box-right'}, 'box-lr' );
replace( replabs, {'apparatus-left', 'apparatus-right'}, 'apparatus-lr' );

roi_types = { 'apparatus-lr', 'box-lr' };
looks_to_types = { 'hand', 'apple' };
meas_types = { 'nfix', 'duration' };

xs = { 'reach_type' };
groups = { 'event' };
panels = { 'target', 'measure', 'roi' };

inds = combvec( 1:numel(roi_types), 1:numel(looks_to_types), 1:numel(meas_types) );

for i = 1:size(inds, 2)
  
  roi_t = roi_types{ inds(1, i) };
  look_t = looks_to_types{ inds(2, i) };
  meas_t = meas_types{ inds(3, i) };
  
  selectors = { 'test-reach', roi_t, meas_type, look_t };
  
  mask = find( replabs, selectors );

  pl = plotlabeled();
  pl.summary_func = @plotlabeled.nanmean;
  pl.error_func = @plotlabeled.nansem;
  pl.one_legend = true;
  pl.x_tick_rotation = 0;
%   pl.shape = [2, 2];
  pl.fig = figure(1);
  pl.match_y_lims = true;
  pl.mask = mask;

  fnames = unique( [xs, groups, panels] );

  axs = pl.bar( alldata, replabs, xs, groups, panels );

  if ( strcmp(meas_type, 'duration') )
    ylabel( axs(1), 'Duration (ms)' );
  else
    assert( strcmp(meas_type, 'nfix') );
    ylabel( axs(1), 'N fixations' );
  end
  
  plot_p = fullfile( base_plotp, meas_t, jjtom.datedir );
  
  if ( do_save )
    shared_utils.io.require_dir( plot_p );
    
    fname = fcat.trim( joincat(prune(replabs(mask)), fnames) );
    fname = sprintf( '%s_%s', prefix, fname );    
    
    jjtom.savefig( gcf, fullfile(plot_p, fname) );
  end
  
end

%%

do_save = false;

prefix = 'combined_bars';

replace( replabs, {'box-left', 'box-right'}, 'box-lr' );
replace( replabs, {'apparatus-left', 'apparatus-right'}, 'apparatus-lr' );

meas_types = { 'nfix', 'duration' };

xs = { 'reach_type' };
groups = { 'event' };
panels = { 'target', 'measure', 'roi' };

inds = combvec( 1:numel(meas_types) );

[to_pltlabs, I] = only( replabs', {'apparatus-lr', 'box-lr', 'hand', 'apple'} );
to_pltdata = alldata(I);

for i = 1:size(inds, 2)
  
  meas_t = meas_types{ inds(1, i) };
  
  selectors = { 'test-reach', meas_t };
  
  mask = find( to_pltlabs, selectors );

  pl = plotlabeled();
  pl.summary_func = @plotlabeled.nanmean;
  pl.error_func = @plotlabeled.nansem;
  pl.one_legend = true;
  pl.x_tick_rotation = 0;
  pl.shape = [2, 2];
  pl.fig = figure(1);
  pl.match_y_lims = true;
  pl.mask = mask;

  fnames = unique( [xs, groups, panels] );

  axs = pl.bar( to_pltdata, to_pltlabs, xs, groups, panels );

  if ( strcmp(meas_t, 'duration') )
    ylabel( axs(1), 'Duration (ms)' );
  else
    assert( strcmp(meas_t, 'nfix') );
    ylabel( axs(1), 'N fixations' );
  end
  
  plot_p = fullfile( base_plotp, meas_t, jjtom.datedir );
  
  if ( do_save )
    shared_utils.io.require_dir( plot_p );
    
    fname = fcat.trim( joincat(prune(replabs(mask)), fnames) );
    fname = sprintf( '%s_%s', prefix, fname );    
    
    jjtom.savefig( gcf, fullfile(plot_p, fname) );
  end
  
end




