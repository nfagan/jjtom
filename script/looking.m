conf = jjtom.config.load();

edf_p = jjtom.get_datadir( 'edf' );
monk_p = jjtom.get_datadir( 'measurements/monkey' );
monitor_p = jjtom.get_datadir( 'measurements/monitor' );
plot_p = fullfile( jjtom.get_datadir('plots'), 'traces', datestr(now, 'mmddyy') );

edf_files = shared_utils.io.find( edf_p, '.mat' );

edf_files = shared_utils.cell.containing( edf_files, 'EpLC' );

save_fig = false;

fix_type = 'eyelink';

evts = 1:6;

look_back = 0e3;
look_ahead = 5e3;

app_consts = jjtom.get_apparatus_constants();
app_dists = jjtom.get_apparatus_distances();
screen_consts = jjtom.get_screen_constants();

% const_dists = jjtom.get_screen_distances();

% t3
% const_dists.monitor_top_to_ground_cm = 93.6;
% app_dists.monitor_origin_to_app_origin_front_cm = -3.1;
% app_dists.monitor_origin_to_app_origin_left_cm = -10;

% EpLC
% const_dists.monitor_top_to_ground_cm = 42.1 + 45.1;
% app_dists.monitor_origin_to_app_origin_front_cm = -16;
% app_dists.monitor_origin_to_app_origin_left_cm = -9.5;

% t2
% const_dists.monitor_top_to_ground_cm = 90.2;
% app_dists.monitor_origin_to_app_origin_front_cm = 14.4;
% app_dists.monitor_origin_to_app_origin_left_cm = -9.5;

height_px = screen_consts.MONITOR_HEIGHT_PX;

padding = struct();
padding.x = 0;
padding.y = 0;

json_func = @(p, id) jsondecode(fileread(fullfile(p, [id, '.json'])));

for j = 1:numel(edf_files)
  
  edf = shared_utils.io.fload( edf_files{j} );  
  id = edf.fileid;
  
  dists = json_func( monk_p, id );
  const_dists = json_func( monitor_p, id );
  
  app_dists.monitor_origin_to_app_origin_front_cm = const_dists.monitor_origin_to_app_origin_front_cm;
  app_dists.monitor_origin_to_app_origin_left_cm = const_dists.monitor_origin_to_app_origin_left_cm;
  
  dists.eye_to_monitor_top_cm = const_dists.monitor_origin_to_ground_cm - dists.eye_to_ground_cm;
  
  plot_fname = sprintf( '%s_pad_%d', edf.fileid, padding.x );

  sync_pulses = strcmp( edf.Events.Messages.info, 'sync' );
  sync_times = edf.Events.Messages.time( sync_pulses );

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

    t = edf.Samples.time;
    start_ind = find( t == start_time + look_back );
    stop_ind = find( t == start_time + look_ahead );

    x = edf.Samples.posX(start_ind:stop_ind);
    y = edf.Samples.posY(start_ind:stop_ind);

    pos = [x(:)'; y(:)'];
    subset_t = t(start_ind:stop_ind)';
    t1 = 20;
    t2 = 15;
    min_dur = 0.05;

    if ( strcmp(fix_type, 'eyelink') )
      fixations = false( 1, numel(edf.Samples.posX) );
      starts = arrayfun( @(x) find(t == x), edf.Events.Efix.start );
      stops = arrayfun( @(x) find(t == x), edf.Events.Efix.end );
      for i = 1:numel(starts)
        fixations(starts(i):stops(i)) = true;
      end
      fixations = fixations(start_ind:stop_ind);
    else
      fixations = is_fixation( pos, subset_t, t1, t2, min_dur ) == 1;
    end

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

    boxl = jjtom.get_lbox_roi( dists, screen_consts, app_dists, app_consts, padding );
    boxr = jjtom.get_rbox_roi( dists, screen_consts, app_dists, app_consts, padding  );
    lemon = jjtom.get_lemon_roi( dists, screen_consts, app_dists, app_consts, padding );

    shared_utils.plot.rect( boxl, ax );
    shared_utils.plot.rect( boxr, ax );
    shared_utils.plot.rect( lemon, ax );

    title_str = sprintf( '%s | Event: %d', id, event_index );

    title( title_str );
    xlabel( 'X Position (px)' );
    ylabel( 'Y Position (px)' );

    % xlim( [-1e3, 2e3] );
    % ylim( [-1e3, 2e3] );

    xlim( [-1e3, 3e3] );
    ylim( [-1e3, 3e3] );

  end
  
  shared_utils.io.require_dir( plot_p );  
  
  if ( save_fig )
    shared_utils.plot.save_fig( gcf, fullfile(plot_p, plot_fname) ...
      , {'epsc', 'png', 'fig'}, true );
  end
end
%%

figure(1); clf();

hold off;

N = numel( fix_starts );

for i = 1:N
  fix_start = fix_starts(i);
  
  if ( i == N )
    fix_stop = numel(x);
  else
    fix_stop = fix_starts(i+1)-1;
  end
  
  subset_x = x(fix_start:fix_stop);
  subset_y = y(fix_start:fix_stop);
  
  cmap = jet( numel(subset_x) );
  
  for j = 1:numel(subset_x)
  
    h = plot( subset_x(j), subset_y(j), 'k*', 'markersize', 1 ); hold on;
    set( h, 'color', cmap(j, :) );
    
  end
  
end

%%

z_far2eye = 76;
x_far2eye = -36;
y_far2eye = 10;

monitor_width_cm = 27 + 21;
monitor_height_cm = 10;
monitor_width_px = 1600;
monitor_height_px = 900;

x_to_monitor = -21;
y_to_monitor = 2;
z_screen = 42;

x_near = jjtom.project_in( z_screen, z_far2eye, x_far2eye );
y_near = jjtom.project_in( z_screen, z_far2eye, y_far2eye );

x_near_from_monitor = x_near - x_to_monitor;
y_near_from_monitor = y_near - y_to_monitor;

x_frac = x_near_from_monitor / monitor_width_cm;
y_frac = y_near_from_monitor / monitor_height_cm;

x_px = monitor_width_px * x_frac;
y_px = monitor_height_px * y_frac;

