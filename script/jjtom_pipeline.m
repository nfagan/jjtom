%%

conf = jjtom.config.load();
% conf.PATHS.data_root = '';

shared = { 'config', conf, 'overwrite', false };

%%  edfs

jjtom.make_edfs( shared{:} );

%%  events

jjtom.make_events( shared{:} );

%%  rois

jjtom.make_rois( shared{:} ...
  , 'pad_x', 10 ...
  , 'pad_y', 10 ...
);