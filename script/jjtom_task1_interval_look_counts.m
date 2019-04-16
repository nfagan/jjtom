function jjtom_task1_interval_look_counts(varargin)

defaults = struct();
defaults.do_save = false;
defaults.config = jjtom.config.load();
defaults.base_subdir = '';
defaults.base_prefix = '';
defaults.is_parallel = true;
defaults.pad_face_y = 0;
defaults.is_per_monkey = false;
defaults.make_figs = true;

params = jjtom.parsestruct( defaults, varargin );

event_pairs = { ...
    {'occluder down', 'fruit in middle'} ...
  , {'fruit leaves box', 'fruit enters box 2'} ...
  , {'fruit in middle', 'shoulder move'} ...
  , {'shoulder move', 'hand in box'} ...
};

look_backs = zeros( size(event_pairs) );
look_aheads = zeros( size(event_pairs) );

look_aheads(end) = 2e3;

look_funcs = { ...
    @jjtom.look_counts.task1_box1 ...
  , @jjtom.look_counts.task1_apple_move ...
  , @jjtom.look_counts.task1_box2 ...
  , @jjtom.look_counts.task1_reach_box ...
};

assert( numel(event_pairs) == numel(look_funcs) );

counts = [];
labels = fcat();

for i = 1:numel(event_pairs)
  count_outputs = jjtom_interval_look_counts_sequence( ...
      'not_files', jjtom.task2_files() ...
    , 'start_event', event_pairs{i}{1} ...
    , 'stop_event', event_pairs{i}{2} ...
    , 'look_back', look_backs(i) ...
    , 'look_ahead', look_aheads(i) ...
    , 'config', params.config ...
    , 'is_parallel', params.is_parallel ...
    , 'pad_face_y', params.pad_face_y ...
  );

  [tmp_counts, labs] = look_funcs{i}( count_outputs );

  append( labels, labs );
  counts = [ counts; tmp_counts ];
end

%%

plot_roi_proportions( counts, labels', params );

% plot_each_monkey( counts, labels', params );
% plot_all_monkeys( counts, labels', params );

end

function p = get_data_p(kind, params, varargin)

p = fullfile( jjtom.get_datadir(kind, params.config), 'interval' ...
  , datestr(now, 'mmddyy'), 'task1', params.base_subdir, varargin{:} );

end

function analysis_p = get_analysis_p(params, varargin)

analysis_p = get_data_p( 'analyses', params, varargin{:} );

end

function plot_p = get_plot_p(params, varargin)

plot_p = get_data_p( 'plots', params, varargin{:} );

end

function rois = get_proportion_rois()

rois = { 'target-roi', 'face', 'other-box', 'boxl', 'boxr', 'box-apple-enters', 'middle_fruit' };

end

function labs = make_proportion_labels(counts, labels)

labs = fcat.like( labels );

for i = 1:numel(counts)
  count = counts(i);
  
  if ( count == 0 )
    continue;
  end
  
  one_labs = prune( labels(i) );
  repmat( one_labs, count );
  append( labs, one_labs );
end

end

function plot_roi_proportions(counts, labels, params)

assert_ispair( counts, labels );

pl = plotlabeled.make_common();
pl.add_points = false;
pl.points_are = 'id';
pl.marker_size = 5;
pl.y_lims = [0, 0.7];

roi_proportion_names = get_proportion_rois();
labels = make_proportion_labels( counts, labels );

mask = fcat.mask( labels ...
  , @findor, roi_proportion_names ...
  , @find, combs(labels, 'monkey') ...
);

fcats = { 'task-interval' };
xcats = { 'roi' };
gcats = { 'task-interval' };
pcats = { 'task-interval' };

if ( params.is_per_monkey )
  pcats{end+1} = 'monkey';
end

pl.x_order = combs( labels, 'task-interval', mask );

fig_I = findall( labels, fcats, mask );

for i = 1:numel(fig_I)
  [props, prop_labels] = proportions_of( labels' ...
    , {'id', 'task-interval'}, 'roi', fig_I{i} );
  
  path_components = { ...
      ternary(params.is_per_monkey, 'per_monkey', 'all_monkeys') ...
    , 'roi_proportions' ...
  };
  
  if ( params.make_figs )
    pl.fig = figure(i);
    axs = pl.bar( props, prop_labels, xcats, gcats, pcats );

    if ( params.do_save )
      plot_p = get_plot_p( params, path_components{:} );
      pltcats = unique( cshorzcat(pcats, gcats) );

      shared_utils.plot.fullscreen( gcf );

      dsp3.req_savefig( gcf, plot_p, prop_labels, pltcats, params.base_prefix );
    end
  end
  
  handle_anova( props, prop_labels', path_components, params );
end

end

function handle_anova(props, prop_labels, path_components, params)

anova_nv_pairs = struct();
anova_nv_pairs.remove_nonsignificant_comparisons = false;

if ( ~params.is_per_monkey )
  collapsecat( prop_labels, 'monkey' );
end

anovas_each = { 'task-interval', 'monkey' };
factor = 'roi';

anova_outs = dsp3.anova1( props, prop_labels', anovas_each, factor, anova_nv_pairs );

if ( params.do_save )
  analysis_p = get_analysis_p( params, path_components{:} );
  
  dsp3.save_anova_outputs( anova_outs, analysis_p, anovas_each );
end

end

function plot_each_monkey(pltdat, pltlabs, params)

pl = plotlabeled.make_common();
pl.add_points = true;
pl.points_are = 'id';
pl.marker_size = 5;
pl.one_legend = false;

mask = fcat.mask( pltlabs ...
  , @find, 'target-roi' ...
  , @find, combs(pltlabs, 'monkey') ...
);

xcats = { 'task-interval' };
gcats = {};
pcats = { 'monkey' };

pl.x_order = combs( pltlabs, 'task-interval', mask );

axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

if ( params.do_save )
  plot_p = get_plot_p( params, 'per_monkey' );
  pltcats = unique( cshorzcat(pcats, gcats) );
  
  shared_utils.plot.fullscreen( gcf );
  
  dsp3.req_savefig( gcf, plot_p, prune(pltlabs(mask)), pltcats, params.base_prefix );
end

end

function plot_all_monkeys(pltdat, pltlabs, params)

pl = plotlabeled.make_common();
pl.add_points = true;
pl.points_are = 'monkey';
pl.marker_size = 5;
pl.point_jitter = 0.05;

mask = fcat.mask( pltlabs ...
  , @find, 'target-roi' ...
  , @findnot, {} ...
);

xcats = { 'task-interval' };
gcats = {};
pcats = {};

pl.x_order = combs( pltlabs, 'task-interval', mask );

axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

if ( params.do_save )
  plot_p = get_plot_p( params, 'all_monkeys' );
  pltcats = unique( cshorzcat(pcats, gcats) );
  
  shared_utils.plot.fullscreen( gcf );
  
  dsp3.req_savefig( gcf, plot_p, prune(pltlabs(mask)), pltcats, params.base_prefix );
end

end

