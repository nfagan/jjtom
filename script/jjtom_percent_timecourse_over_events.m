tic;

conf = jjtom.config.load();

samp_p = jjtom.get_datadir( 'edf/samples', conf );
roi_p = jjtom.get_datadir( 'roi', conf );
lab_p = jjtom.get_datadir( 'labels', conf );

evt_mats = jjtom.get_datafiles( 'events', conf );

timecourse = {};
eventinds = [];
evtnames = {};
taxis = {};
timelabs = setdisp( fcat(), 'short' );

use_evts = { 'od-3', 'test-reach' };

look_ahead = 10e3;
add_bin = true;
bin_size = 500;

for i = 1:numel(evt_mats)
  shared_utils.general.progress( i, numel(evt_mats) );
  
  evt_file = jjtom.fload( evt_mats{i} );
  fname = jjtom.ext( evt_file.fileid, '.mat' );
  lab_file = jjtom.fload( fullfile(lab_p, fname) );
  samp_file = jjtom.fload( fullfile(samp_p, fname) );
  roi_file = jjtom.fload( fullfile(roi_p, fname) );
  
  metalabs = fcat.from( lab_file.labels, lab_file.categories );
  
  [~, use_evts_ind] = ismember( use_evts, evt_file.key );
  assert( ~any(use_evts_ind == 0), 'Some events did not exist.' );
  
  evts = evt_file.events(use_evts_ind);
  evt_names = evt_file.key(use_evts_ind);
  
  t = samp_file.t(:);
  x = samp_file.x(:);
  y = samp_file.y(:);
  
  rois = struct2cell( roi_file.rois );
  roi_names = fieldnames( roi_file.rois );
  
  start = t == evts(1);
  stop = t == evts(end) + look_ahead;

  assert( sum(start) == 1 && sum(stop) == 1, 'No matching start or stop.' );
  
  start = find( start );
  stop = find( stop );
  
  rel0_events = evts-evts(1) + 1;
  
  for j = 1:numel(rois)
    ib_pos = jjtom.rectbounds( x, y, rois{j} );
    
    jointlabs = join( setcat(addcat(fcat(), 'roi'), 'roi', roi_names{j}), metalabs );
    
    ib_pos = ib_pos(start:stop);
    some_t = t(start:stop);
    
    if ( add_bin )
      N = bin_size;
      stp = 1;
      assign_stp = 1;
      
      ib_pos2 = [];
      t_axis = [];
      evt_inds = zeros( 1, numel(evts) );
      
      while ( stp < numel(ib_pos) )
        end_ind = min( stp+N-1, numel(ib_pos) );
        ind = stp:end_ind;
        
        subset_t = some_t(ind);
        
        ib_pos2(1, assign_stp) = sum(ib_pos(ind)) / numel( ind );
        t_axis(1, assign_stp) = subset_t(1) - some_t(1) + 1;
        
        is_this_bin = ismember( evts, subset_t );
        evt_inds(is_this_bin) = assign_stp;
        
        stp = stp + N;
        assign_stp = assign_stp + 1;
      end
      
      assert( ~any(evt_inds == 0), 'Some events were not assigned.' );
    else
      ib_pos2 = ib_pos;
      evt_inds = rel0_events(:)';
      t_axis = some_t;
    end
    
    timecourse{end+1, 1} = ib_pos2;
    eventinds = [ eventinds; evt_inds ];
    evtnames = [ evtnames; evt_names(:)' ];
    taxis = [ taxis; t_axis ];
    
    append( timelabs, jointlabs );
  end
end

%%

f = figure(1);
clf( f );

mask = find( timelabs, {'consistent', 'apparatusl', 'apparatusr'} );
panels = { 'monkey', 'reach_type', 'reach_direction' };
lines = { 'reach_type', 'roi' };

id_ind = findall( timelabs, 'id', mask );

shp = plotlabeled.try_subplot_shape( [4, 2], numel(id_ind) );
% shp = plotlabeled.get_subplot_shape( numel(id_ind) );

for i = 1:numel(id_ind)
  ax = subplot( shp(1), shp(2), i );
  set( ax, 'nextplot', 'add' );
  
  line_i = findall( timelabs, getcats(timelabs), id_ind{i} );
  L = numel( line_i );
  
  hs = gobjects( 1, L );
  leg_labs = cell( size(hs) );
  
  for j = 1:L
    line_ind = line_i{j};
    
    assert( numel(line_ind) == 1 );
    
    ib = timecourse{line_ind, :};
    evt_inds = eventinds(line_ind, :);
    names = evtnames(line_ind, :);
    ts = taxis{line_ind, :} / 1e3;
    evt_inds = arrayfun( @(x) ts(x), evt_inds );
    
    hs(j) = plot( ax, ts, ib );
    
    leg_labs{j} = strjoin( columnize(combs(timelabs, lines, line_ind)), ' | ' );
    
    verts = shared_utils.plot.add_vertical_lines( ax, evt_inds, 'k--' );    
    set( verts, 'linewidth', 2 );
    
    arrayfun( @(x, txt) text(ax, x, 0.5, txt{1}), evt_inds, names );
  end
  
  title_labs = strjoin( columnize(combs(timelabs, panels, id_ind{i})), ' | ' );
  title( ax, title_labs );
  
  legend( hs, leg_labs );
  
end

