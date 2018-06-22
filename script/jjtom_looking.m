conf = jjtom.config.load();

edf_files = jjtom.get_datafiles( 'edf', conf, '.mat' );
roi_p = jjtom.get_datadir( 'roi' );
plot_p = fullfile( conf.PATHS.data_root, 'plots', 'traces', datestr(now, 'mmddyy') );

eph_edfs = shared_utils.cell.containing( edf_files, {'Ly'} );
% t_edfs = shared_utils.cell.containing( edf_files, {'Ta'} );
t_edfs = [];

edf_files = [ eph_edfs, t_edfs ];

evts = 5:6;
look_back = -2e3;
look_ahead = 5e3;

%%

save_fig = true;

for j = 1:numel(edf_files)
  
  edf_file = shared_utils.io.fload( edf_files{j} );  
  
  id = edf_file.fileid;
  
  roi_file = shared_utils.io.fload( fullfile(roi_p, jjtom.ext(id, '.mat')) );

  sync_pulses = strcmp( edf_file.Events.Messages.info, 'sync' );
  sync_times = edf_file.Events.Messages.time( sync_pulses );
  
  plot_fname = id;

  %  plot fixations as solid color

  f = figure(1); clf();
  set( f, 'units', 'normalized' );
  set( f, 'position', [0, 0, 1, 1] );

  hold off;
  
  within_evt_bounds = evts <= numel(sync_times);
  
  evts = evts(within_evt_bounds);

  shape = shared_utils.plot.get_subplot_shape( numel(evts) );

  for idx = 1:numel(evts)

    ax = subplot( shape(1), shape(2), idx );
    set( ax, 'nextplot', 'replace' );

    event_index = evts(idx);

    start_time = sync_times(event_index);

    t = edf_file.Samples.time;
    start_ind = find( t == start_time + look_back );
    stop_ind = find( t == start_time + look_ahead );

    x = edf_file.Samples.posX(start_ind:stop_ind);
    y = edf_file.Samples.posY(start_ind:stop_ind);

    fixations = false( 1, numel(edf_file.Samples.posX) );
    starts = arrayfun( @(x) find(t == x), edf_file.Events.Efix.start );
    stops = arrayfun( @(x) find(t == x), edf_file.Events.Efix.end );

    for i = 1:numel(starts)
      fixations(starts(i):stops(i)) = true;
    end

    fixations = fixations(start_ind:stop_ind);

    % fix_starts = shared_utils.logical.find_starts( fixations(:)', 50 );
    [fix_starts, fix_durs] = shared_utils.logical.find_all_starts( fixations(:)' );
    ind = fix_durs >= 25;

    fix_starts = fix_starts(ind);
    fix_stops = fix_starts + fix_durs(ind) - 1;

    N = numel( fix_starts );
    cmap = hot( N );

    h = plot( ax, x, y, '*', 'markersize', 0.001 ); hold on;
    set( h, 'color', [0.9, 0.9, 0.9] );

    for i = 1:N
      fix_start = fix_starts(i);

      fix_stop = fix_stops(i);    

      subset_x = x(fix_start:fix_stop);
      subset_y = y(fix_start:fix_stop);

      h = plot( ax, subset_x, subset_y, 'k*', 'markersize', 4 );

      set( h, 'color', cmap(i, :) );
    end

    if ( N > 0 )
      colorbar;
      colormap( cmap );
      caxis( [1, N] );
    end

    boxl = roi_file.rois.boxl;
    boxr = roi_file.rois.boxr;
    lemon = roi_file.rois.lemon;
    
    cellfun( @(x) shared_utils.plot.rect(x, ax), {boxl, boxr, lemon} );

    title_str = sprintf( '%s | Event: %d', id, event_index );

    title( title_str );
    xlabel( 'X Position (px)' );
    ylabel( 'Y Position (px)' );

    % xlim( [-1e3, 2e3] );
    % ylim( [-1e3, 2e3] );

    xlim( [-1e3, 3e3] );
    ylim( [-1e3, 3e3] );

  end
  
  if ( save_fig )
    shared_utils.io.require_dir( plot_p );
    shared_utils.plot.save_fig( gcf, fullfile(plot_p, plot_fname) ...
      , {'epsc', 'png', 'fig'}, true );
  end
end