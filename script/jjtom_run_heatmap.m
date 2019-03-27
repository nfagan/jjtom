% file_spec = { 'not_files', [jjtom.task2_files(), jjtom.jess_files()] };
file_spec = { 'files', jjtom.task2_files() };

% {'occluder down', 'fruit in middle'}

sample_outs = jjtom_looking_heatmap( ...
  file_spec{:} ...
  , 'start_event', 'occluder down' ...
  , 'stop_event', 'fruit in middle' ...
  , 'normalizing_x_limits', [-0.3, 1.3] ...
  , 'normalizing_y_limits', [-0.3, 1.3] ...
  , 'normalizing_bin_size', 0.01 ...
);

%%

x_edges = sample_outs.x_edges;
y_edges = sample_outs.y_edges;

select_trials = find( sample_outs.labels, 'kuro' );

total_counts = sum_many( sample_outs.hist{select_trials} );

total_counts = imgaussfilt( total_counts, 2 );

ax = gca();
cla( ax );

scaled = imagesc( ax, flipud(total_counts) );

set( ax, 'xtick', 1:numel(x_edges) );
set( ax, 'ytick', 1:numel(y_edges) );

plt_y = flip( y_edges );

shared_utils.plot.fseries_yticks( ax, plt_y, 10 );
shared_utils.plot.tseries_xticks( ax, x_edges, 10 );
shared_utils.plot.hold( ax, 'on' );

shared_utils.plot.add_vertical_lines( ax, find(x_edges == 0 | x_edges == 1), 'r' );
shared_utils.plot.add_horizontal_lines( ax, find(plt_y == 0 | plt_y == 1), 'r' );