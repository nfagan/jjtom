tic;

conf = jjtom.tmp_setdataroot( '/Volumes/My Passport/NICK/Chang Lab 2016/jess/tom' );

plot_p = fullfile( conf.PATHS.data_root, 'plots', 'p_inbounds', datestr(now, 'mmddyy') );

samp_p = jjtom.get_datadir( 'edf/samples', conf );
roi_p = jjtom.get_datadir( 'roi', conf );
lab_p = jjtom.get_datadir( 'labels', conf );

% files = { 'KrLu', 'KrRu', 'KrLe', 'KrRe' };
files = {};
not_files = {'Kr', 'Cn'};

evt_mats = jjtom.get_datafiles( 'events', conf );
evt_mats = shared_utils.io.filter_files( evt_mats, files, not_files );

bin_width = 250;
look_back = -3e3;
look_ahead = 3e3;
look_ahead = look_ahead + bin_width;

bin_ts = look_back:bin_width:look_ahead;

tcourses = cell( size(evt_mats) );
tlabs = cell( size(tcourses) );

parfor i = 1:numel(evt_mats)
  evt_file = jjtom.fload( evt_mats{i} );
  fname = jjtom.ext( evt_file.fileid, '.mat' );
  lab_file = jjtom.fload( fullfile(lab_p, fname) );
  samp_file = jjtom.fload( fullfile(samp_p, fname) );
  roi_file = jjtom.fload( fullfile(roi_p, fname) );
  
  metalabs = fcat.from( lab_file.labels, lab_file.categories );
  
  evts = evt_file.events;
  
  t = samp_file.t(:);
  x = samp_file.x(:);
  y = samp_file.y(:);
  
  rois = struct2cell( roi_file.rois );
  roi_names = fieldnames( roi_file.rois );
  
  inds = combvec( 1:numel(evts), 1:numel(roi_names) );
  n_combs = size( inds, 2 );
  
  ibs = false( numel(rois), numel(x) );
  
  for j = 1:numel(rois)
    ibs(j, :) = jjtom.rectbounds( x, y, rois{j} );
  end
  
  tmp_labs = fcat();
  tmp_dat = [];
  
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
    jointlabs = join( evtlabs', metalabs );
    
    start = evt + look_back;
    stop = evt + look_ahead;
    
    ib_pos = columnize( ibs(roi_ind, :) );
    
    binned_n = zeros( 1, numel(bin_ts)-1 );
    
    for k = 1:numel(bin_ts)-1
      ib_t = t >= evt + bin_ts(k) & t <= evt + bin_ts(k+1);
      binned_n(k) = sum( ib_t & ib_pos ) / sum( ib_t ) * 100;
    end
    
    tmp_dat = [ tmp_dat; binned_n ];
    append( tmp_labs, jointlabs );
  end
  
  tcourses{i} = tmp_dat;
  tlabs{i} = tmp_labs;
end

timecourse = vertcat( tcourses{:} );
timelabs = vertcat( fcat(), tlabs{:} );

toc;
%%
tic;
pltlabs = timelabs';

all_apples = jjtom.get_apple_indices( pltlabs );
all_hands = jjtom.get_hand_indices( pltlabs );

% setcat( addcat(pltlabs, 'target'), 'target', 'apple', all_apples );
% setcat( addcat(pltlabs, 'target'), 'target', 'hand', all_hands );

replace( pltlabs, 'left', 'reach-to-left' );
replace( pltlabs, 'right', 'reach-to-right' );
replace( pltlabs, 'apparatusl', 'apparatus-left' );
replace( pltlabs, 'apparatusr', 'apparatus-right' );
replace( pltlabs, 'boxl', 'box-left' );
replace( pltlabs, 'boxr', 'box-right' );

full_labs = pltlabs';

addcat( pltlabs, 'target' );

handlabs = keep( pltlabs', all_hands );
applelabs = keep( pltlabs', all_apples );

setcat( handlabs, 'target', 'hand' );
setcat( applelabs, 'target', 'apple' );

pltlabs = append( handlabs', applelabs );
pltdata = [ timecourse(all_hands, :); timecourse(all_apples, :) ];

toc;
%%

do_save = true;

prefix = 'percent_inbounds_full';
selectors = { 'test-reach', 'apparatus-left', 'apparatus-right', 'reach-to-right' };

mask = find( full_labs, selectors );

pl = plotlabeled();
pl.fig = figure(1);
pl.summary_func = @plotlabeled.nanmean;
pl.error_func = @plotlabeled.nansem;
pl.one_legend = true;
pl.x_tick_rotation = 0;
pl.shape = [4, 2];
pl.x = bin_ts(1:end-1);
pl.mask = mask;

lines = { 'roi' };
panels = { 'monkey', 'event', 'reach_type', 'reach_direction' };
fnames_are = lines;

evtname = strjoin( columnize(combs(full_labs, 'event', pl.mask)), ' | ' );

axs = pl.lines( timecourse, full_labs, lines, panels );

ylabel( axs(1), '% in bounds' );
xlabel( axs(1), sprintf('Time (ms) from "%s"', evtname) );

set( axs, 'nextplot', 'add' );

shared_utils.plot.add_vertical_lines( axs, 0 );

if ( do_save )
  fname = jjtom.fname( full_labs, fnames_are, mask );
  fname = sprintf( '%s_%s_%s', prefix, strjoin(selectors, '_'), fname );
  
  shared_utils.io.require_dir( plot_p );
  jjtom.savefig( gcf, fullfile(plot_p, fname) );
end

%%  plot per panel

do_save = true;
prefix = 'percent_inbounds';

to_pltlabs = pltlabs';
replace( to_pltlabs, {'box-left', 'box-right'}, 'box-lr' );
replace( to_pltlabs, {'apparatus-left', 'apparatus-right'}, 'apparatus-lr' );

% selectors = { 'test-reach', 'box-lr', 'hand' };
selectors = { 'test-reach', 'apparatus-lr', 'apple' };

mask = find( to_pltlabs, selectors );

pl = plotlabeled();
pl.fig = figure(1);
pl.summary_func = @plotlabeled.nanmean;
pl.error_func = @plotlabeled.nansem;
pl.one_legend = true;
pl.x_tick_rotation = 0;
pl.x = bin_ts(1:end-1);
pl.add_errors = false;
pl.mask = mask;

lines = { 'reach_type' };
panels = { 'monkey', 'event', 'target', 'roi' };

fnames_are = union( lines, panels );

evtname = jjtom.fname( to_pltlabs, 'event', mask );

axs = pl.lines( pltdata, to_pltlabs, lines, panels );

ylabel( axs(1), '% in bounds' );
xlabel( axs(1), sprintf('Time (ms) from "%s"', evtname) );

set( axs, 'nextplot', 'add' );

shared_utils.plot.add_vertical_lines( axs, 0 );
shared_utils.plot.add_horizontal_lines( axs, 50 );

if ( do_save )
  fname = jjtom.fname( to_pltlabs, fnames_are, mask );
  fname = sprintf( '%s_%s_%s', prefix, strjoin(selectors, '_'), fname );
  
  shared_utils.io.require_dir( plot_p );
  jjtom.savefig( gcf, fullfile(plot_p, fname) );
end







