function jjtom_task2_interval_look_counts(varargin)

defaults = struct();
defaults.do_save = false;
defaults.config = jjtom.config.load();
defaults.base_subdir = '';
defaults.base_prefix = '';
defaults.pad_face_y = 0;

params = jjtom.parsestruct( defaults, varargin );

event_pairs = { ...
    {'occluder down', 'fruit in middle'} ... % box 1
  , {'fruit leaves box', 'fruit enters box 2'} ...  % apple move
  , {'fruit in middle', 'fruit enters box 2'} ... % box 2 (box apple is in)
  , {'head starts to move', 'head reappears'} ... % head occluded (all face)
  , {'apple reappears', 'fruit enters box 3'} ... % apple move (again)
  , {'fruit enters box 3', 'shoulder move'} ... % box 3 (box apple is in)
  , {'shoulder move', 'hand in box'} ...  % reach box (box hand is in)
};

look_backs = zeros( size(event_pairs) );
look_aheads = zeros( size(event_pairs) );

look_aheads(end) = 2e3; % look 2s after hand in box

look_funcs = { ...
    @jjtom.look_counts.task2_box1 ...
  , @jjtom.look_counts.task2_apple_move ...
  , @jjtom.look_counts.task2_box2 ...
  , @jjtom.look_counts.task2_head_occluded ...
  , @jjtom.look_counts.task2_apple_move2 ...
  , @jjtom.look_counts.task2_box3 ...
  , @jjtom.look_counts.task2_reach_box ...
};

assert( numel(event_pairs) == numel(look_funcs) );

counts = [];
labels = fcat();

for i = 1:numel(event_pairs)
  count_outputs = jjtom_interval_look_counts_sequence( ...
      'files', jjtom.task2_files() ...
    , 'start_event', event_pairs{i}{1} ...
    , 'stop_event', event_pairs{i}{2} ...
    , 'look_ahead', look_aheads(i) ...
    , 'look_back', look_backs(i) ...
    , 'config', params.config ...
    , 'pad_face_y', params.pad_face_y ...
  );

  [tmp_counts, labs] = look_funcs{i}( count_outputs );

  append( labels, labs );
  counts = [ counts; tmp_counts ];
end

plot_each_monkey( counts, labels', params );
plot_all_monkeys( counts, labels', params );

end

function plot_p = get_plot_p(params, varargin)

plot_p = fullfile( jjtom.get_datadir('plots', params.config), 'interval' ...
  , datestr(now, 'mmddyy'), 'task2', params.base_subdir, varargin{:} );

end

function plot_each_monkey(counts, labels, params)

pl = plotlabeled.make_common();
pl.add_points = true;
pl.points_are = 'id';
pl.marker_size = 5;
pl.point_jitter = 0.05;

pltdat = counts;
pltlabs = labels';

mask = fcat.mask( pltlabs ...
  , @find, 'target-roi' ...
  , @find, {'cron', 'kuro'} ...
);

xcats = { 'task-interval' };
gcats = {};
pcats = { 'monkey' };

pl.x_order = combs( pltlabs, 'task-interval', mask );
pl.one_legend = false;

axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

if ( params.do_save )
  plot_p = get_plot_p( params, 'per_monkey' );
  pltcats = unique( cshorzcat(pcats, gcats) );
  
  shared_utils.plot.fullscreen( gcf );
  
  dsp3.req_savefig( gcf, plot_p, prune(pltlabs(mask)), pltcats, params.base_prefix );
end

end

function plot_all_monkeys(counts, labels, params)

pl = plotlabeled.make_common();
pl.add_points = true;
pl.points_are = 'monkey';
pl.marker_size = 5;
pl.point_jitter = 0.05;

pltdat = counts;
pltlabs = labels';

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