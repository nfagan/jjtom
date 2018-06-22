conf = jjtom.config.load();

fix_p = jjtom.get_datadir( 'edf/events', conf );
roi_p = jjtom.get_datadir( 'roi', conf );
lab_p = jjtom.get_datadir( 'labels', conf );

evt_mats = jjtom.get_datafiles( 'events', conf );

min_dur = 25;
look_back = -3e3;
look_ahead = 0e3;

bin_width = 500;
bin_ts = look_back:bin_width:look_ahead;

timecourse = [];
timelabs = fcat();

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
    
    binned_n = zeros( 1, numel(bin_ts)-1 );
    
    ib_pos = jjtom.rectbounds( fix_x, fix_y, roi );
    
    for k = 1:numel(bin_ts)-1
      ib_t = fix_starts >= evt + bin_ts(k) & fix_starts <= evt + bin_ts(k+1);
      
      binned_n(k) = sum( ib_t & ib_pos );
    end
    
    timecourse = [ timecourse; binned_n ];
    
    append( timelabs, jointlabs );
  end    
end

%%

pl = plotlabeled();
pl.summary_func = @plotlabeled.nanmean;
pl.error_func = @plotlabeled.nansem;
pl.one_legend = true;
pl.x_tick_rotation = 0;
pl.shape = [4, 2];
pl.fig = figure(1);
pl.x = bin_ts(1:end-1);
pl.mask = find( timelabs, {'test-reach', 'boxl', 'boxr'} );

replace( timelabs, 'left', 'reach-type-left' );
replace( timelabs, 'right', 'reach-type-right' );

axs = pl.lines( timecourse, timelabs, {'roi', 'reach_direction'}, {'monkey', 'event', 'reach_type'} );
ylabel( axs(1), 'N Fixations' );
