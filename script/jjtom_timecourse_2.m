function jjtom_timecourse_2(varargin)

defaults.target_roi = 'apparatus-lr';
defaults.do_save = false;
defaults.do_normalize = true;
defaults.config = jjtom.config.load();
defaults.files = {};
defaults.not_files = {};
defaults.look_back = -3e3;
defaults.look_ahead = 3.5e3;

params = dsp3.parsestruct( defaults, varargin );

conf = params.config;

base_plotp = fullfile( conf.PATHS.data_root, 'plots' );

fix_p = jjtom.get_datadir( 'edf/events', conf );
roi_p = jjtom.get_datadir( 'roi', conf );
lab_p = jjtom.get_datadir( 'labels', conf );

evt_mats = jjtom.get_datafiles( 'events', conf );
evt_mats = shared_utils.io.filter_files( evt_mats, params.files, params.not_files );

min_dur = 25;
look_back = params.look_back;
look_ahead = params.look_ahead;

bin_width = 500;
bin_ts = look_back:bin_width:look_ahead;

timecourse = [];
dur_timecourse = [];
timelabs = fcat();

do_normalize = params.do_normalize;
normlabs = fcat();
normdat = [];

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
    
    evtlabs = setcat( addcat(fcat(), cats), cats, labs );
    jointlabs = join( evtlabs, metalabs );
    
    start = evt + look_back;
    stop = evt + look_ahead;
    
    binned_n = zeros( 1, numel(bin_ts)-1 );
    binned_dur = zeros( size(binned_n) );
    
    ib_pos = jjtom.rectbounds( fix_x, fix_y, roi );
    
    for k = 1:numel(bin_ts)-1
      ib_t = fix_starts >= evt + bin_ts(k) & fix_starts <= evt + bin_ts(k+1);
      
      ib = ib_t & ib_pos;
      
      binned_n(k) = sum( ib );
      binned_dur(k) = sum( fix_durs(ib) );
    end
    
    timecourse = [ timecourse; binned_n ];
    dur_timecourse = [ dur_timecourse; binned_dur ];
    
    append( timelabs, jointlabs );
  end    
  
  %
  % norm
  %
  
  evt1 = strcmp( evt_file.key, 'od-3' );
  evt2 = strcmp( evt_file.key, 'test-reach' );
  assert( sum(evt1 | evt2) == 2, 'Missing events' );
  
  evt1 = evt_file.events(evt1);
  evt2 = evt_file.events(evt2);
  
  ib_t = fix_starts >= evt1 & fix_starts <= evt2;
  
  for j = 1:numel(rois)
    roi = rois{j};
    
    ib_pos = jjtom.rectbounds( fix_x, fix_y, roi );
    
    ib_evts = ib_t & ib_pos;
    
    evtlabs = setcat( addcat(fcat(), 'roi'), 'roi', roi_names{j} );
    jointlabs = join( evtlabs, metalabs );
    
    append( normlabs, jointlabs );
    normdat = [ normdat; sum(fix_durs(ib_evts)) ];
  end
end

%%  norm

if ( do_normalize )
  [I_time, C] = findall( timelabs, getcats(normlabs) );
  
  for i = 1:numel(I_time)
    matching = find( normlabs, C(:, i) );
    
    assert( numel(matching) == 1 );
    
    dur_timecourse(I_time{i}, :) = dur_timecourse(I_time{i}, :) ./ normdat(matching);
  end
end

%%
tic;

pltlabs = timelabs';

all_apples = jjtom.get_apple_indices( pltlabs );
all_hands = jjtom.get_hand_indices( pltlabs );

addcat( pltlabs, 'target' );

replace( pltlabs, 'left', 'reach-to-left' );
replace( pltlabs, 'right', 'reach-to-right' );
replace( pltlabs, 'apparatusl', 'apparatus-left' );
replace( pltlabs, 'apparatusr', 'apparatus-right' );
replace( pltlabs, 'boxl', 'box-left' );
replace( pltlabs, 'boxr', 'box-right' );
replace( pltlabs, 'facel', 'face-left' );
replace( pltlabs, 'facer', 'face-right' );

handlabs = setcat( pltlabs', 'target', 'apple', all_apples );
applelabs = setcat( pltlabs', 'target', 'hand', all_hands );

roilabs = append( handlabs', applelabs );

replabs = repset( addcat(roilabs', 'measure'), 'measure', {'nfix', 'duration'} );
prune( replabs );

%   append binned duration to binned n-fixations
alldat = [ rowrep(timecourse, 2); rowrep(dur_timecourse, 2) ];

toc;

%%  updated time course

do_save = params.do_save;
prefix = 'timecourse';
target_roi = params.target_roi;

normpref = ternary( do_normalize, 'normalized', 'non-normalized' );
prefix = sprintf( '%s_%s', normpref, prefix );

to_pltlabs = replabs';
to_pltdata = alldat;

replace( to_pltlabs, {'box-left', 'box-right'}, 'box-lr' );
replace( to_pltlabs, {'apparatus-left', 'apparatus-right'}, 'apparatus-lr' );
replace( to_pltlabs, {'face-left', 'face-right'}, 'face-lr' );

subsets = { 'apple', 'hand' };

[I, C] = findall( to_pltlabs, {'target', 'measure'}, find(to_pltlabs, subsets) );

selectors = { 'test-reach', target_roi };

for i = 1:numel(I)
  
  mask = find( to_pltlabs, selectors, I{i} );

  pl = plotlabeled();
  pl.summary_func = @plotlabeled.nanmean;
  pl.error_func = @plotlabeled.nansem;
  pl.one_legend = true;
  pl.x_tick_rotation = 0;
  pl.shape = [2, 2];
  pl.fig = figure(1);
  pl.x = bin_ts(1:end-1);
  pl.add_errors = false;
  pl.mask = mask;
  
  meas_t = C{2, i};
  
  if ( strcmp(meas_t, 'nfix') )
    ylab = 'N fixations';
  else
    assert( strcmp(meas_t, 'duration') );
    
    if ( do_normalize )
      ylab = 'Normalized duration';
    else
      ylab = 'Duration ms';
    end
  end
  
  plot_subdir = sprintf( '%s_timecourse', meas_t );
  plot_p = fullfile( base_plotp, plot_subdir, jjtom.datedir() );

  lines = { 'reach_type' };
  panels = { 'monkey', 'event', 'target', 'roi' };

  fnames_are = union( lines, panels );

  axs = pl.lines( to_pltdata, to_pltlabs, lines, panels );
  ylabel( axs(1), ylab );

  set( axs, 'nextplot', 'add' );
  shared_utils.plot.add_vertical_lines( axs, 0 );

  if ( do_save )
    fname = sprintf('%s_%s', prefix, jjtom.fname(to_pltlabs, fnames_are, mask) );
    shared_utils.io.require_dir( plot_p );
    jjtom.savefig( gcf, fullfile(plot_p, fname) );
  end

end

end