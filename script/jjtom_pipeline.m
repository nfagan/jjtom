%%

conf = jjtom.config.load();

shared = { 'config', conf, 'overwrite', true };

%%  unified

jjtom.make_unified( shared{:} );

%%  labels

jjtom.make_labels( shared{:} );

%%  edfs

jjtom.make_edfs( shared{:} );
jjtom.make_edf_events( shared{:} );
jjtom.make_edf_samples( shared{:} );

%%  events

jjtom.make_events( shared{:} );

%%  rois

jjtom.make_rois( shared{:} ...
  , 'pad_x', 15 ...
  , 'pad_y', 5 ...
);