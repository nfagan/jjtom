function jjtom_final_task2_look_plots(varargin)

defaults = jjtom.get_common_make_defaults();
defaults.do_save = false;
defaults.make_figs = true;
defaults.base_subdir = '';

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;

kuro_files = { 'KrLu', 'KrRu', 'KrLe', 'KrRe' };
cron_files = { 'CnLu', 'CnRu', 'CnLe', 'CnRe' };

files = union( kuro_files, cron_files );

look_ahead = 6e3;
look_back = 0;
is_normalized = true;
bin_width = 500;

outs = jjtom_get_looking_probability_timecourse( ...
    'config', conf ...
  , 'files', files ...
  , 'bin_width', bin_width ...
  , 'look_back', look_back ...
  , 'look_ahead', look_ahead ...
  , 'is_parallel', true ...
  , 'separate_apparatus_and_face', true ...
  , 'normalize_looking_duration', is_normalized ...
  , 'proportional_fixation_looking_duration', false ...
  , 'maximum_normalization_window', Inf ...
  , 'fixation_looking_duration_proportions_each', {'apparatusl', 'apparatusr', 'face'} ...
  , 'event_subdir', 'recoded_events' ...
  , 'recoded_normalization_event_name', 'occluder down' ...
  , 'recoded_normalization_look_ahead', 3e3 ...
  , 'normalize_per_roi', false ...
);

params.plot_p = jjtom.get_datadir( 'plots', conf );
params.analysis_p = jjtom.get_datadir( 'analyses', conf );

%%

handle_overall( outs, params );
handle_per_roi( outs, params );

end

function handle_overall(outs, params)

%%  looking duratinon -- to apparatus overall

base_subdir = params.base_subdir;

pltdat = outs.looking_duration;
pltlabs = outs.labels';

assert_ispair( pltdat, pltlabs );

mask = fcat.mask( pltlabs ...
  , @find, {'hand in box'} ...
  , @find, {'apparatus'} ...
);

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;
pl.fig = figure(3);

xcats = { 'roi' };
gcats = { 'expected_type' };
pcats = { 'event' };

if ( params.make_figs )
  axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

  if ( params.do_save )
    save_p = fullfile( params.plot_p, 'duration', dsp3.datedir, 'task2', base_subdir );
    dsp3.req_savefig( gcf, save_p, pltlabs(mask), cshorzcat(gcats, pcats, xcats) ...
      , 'overall_' );
  end
end

%%  ttest
  
ttest_mask = intersect( mask, find(~isnan(pltdat)) );

for i = 1:2
  test_each = ternary( i == 1, {'monkey', 'roi'}, {'roi'} );
  monk_dir = ternary( i == 1, 'per-monk', 'all-monks' );    

  ttest_outs = dsp3.ttest2( pltdat, pltlabs', test_each, 'expected', 'unexpected' ...
    , 'mask', ttest_mask );

  if ( params.do_save )
    plot_path_components = fullfile( 'duration', dsp3.datedir, 'task2' ...
      , 'overall', base_subdir, monk_dir );
    analysis_p = fullfile( params.analysis_p, plot_path_components );

    dsp3.save_ttest2_outputs( ttest_outs, analysis_p );
  end
end

end

function handle_per_roi(outs, params)

base_subdir = params.base_subdir;

use_rois = { 'face', 'apparatus', 'box' };

for i = 1:numel(use_rois)
  left_roi = sprintf( '%sl', use_rois{i} );
  right_roi = sprintf( '%sr', use_rois{i} );

  pltdat = outs.looking_duration;
  pltlabs = outs.labels';

  assert_ispair( pltdat, pltlabs );

  mask = fcat.mask( pltlabs ...
    , @find, {'hand in box'} ...
    , @find, {left_roi, right_roi} ...
  );

  replace( pltlabs, {'apparatusl', 'apparatusr'}, 'apparatus-lr' );
  replace( pltlabs, {'facel', 'facer'}, 'face-lr' );
  replace( pltlabs, {'boxl', 'boxr'}, 'box-lr' );

  pl = plotlabeled.make_common();
  pl.x_tick_rotation = 0;
  pl.fig = figure(3);

  xcats = { 'expected_type' };
  gcats = { 'roi' };
  pcats = { 'event' };

  if ( params.make_figs )
    axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

    if ( params.do_save )
      save_p = fullfile( params.plot_p, dsp3.datedir, 'task2' ...
        , 'per_side', base_subdir );
      dsp3.req_savefig( gcf, save_p, pltlabs(mask), cshorzcat(gcats, pcats, xcats) ...
        , 'side_' );
    end
  end
  
  %%  ttest
  
  ttest_mask = intersect( mask, find(~isnan(pltdat)) );
  
  for j = 1:2
    test_each = ternary( j == 1, {'monkey', 'roi'}, {'roi'} );
    monk_dir = ternary( j == 1, 'per-monk', 'all-monks' );    

    ttest_outs = dsp3.ttest2( pltdat, pltlabs', test_each, 'expected', 'unexpected' ...
      , 'mask', ttest_mask );

    if ( params.do_save )
      plot_path_components = fullfile( 'duration', dsp3.datedir, 'task2' ...
        , 'per_side', base_subdir, monk_dir);
      analysis_p = fullfile( params.analysis_p, plot_path_components );

      dsp3.save_ttest2_outputs( ttest_outs, analysis_p );
    end
  end
end

end