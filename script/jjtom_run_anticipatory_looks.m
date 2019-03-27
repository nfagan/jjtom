%%  task1

do_save = true;

sequence_outputs = jjtom_interval_look_counts_sequence( ...
    'not_files', jjtom.task2_files() ...
  , 'start_event', 'fruit enters box 2' ...
  , 'stop_event', 'shoulder move' ...
  , 'look_back', 0 ...
  , 'look_ahead', 0 ...
  , 'is_parallel', true ...
  , 'pad_face_y', 0.05 ...
);

roi_sequence = sequence_outputs.roi_sequence';
rois = { 'face', 'boxl', 'boxr' };

[anticipatory_looks_to, labels] = jjtom_anticipatory_looks( roi_sequence, rois );

tbl = jjtom_anticipatory_looks_to_table( anticipatory_looks_to, labels );

if ( do_save )
  analysis_p = fullfile( jjtom.get_datadir('analyses'), dsp3.datedir, 'anticipatory', 'task1' );
  shared_utils.io.require_dir( analysis_p );
  
  dsp3.writetable( tbl, fullfile(analysis_p, 'anticipatory_look_info') );
end

%%  task2

do_save = true;

sequence_outputs = jjtom_interval_look_counts_sequence( ...
    'files', jjtom.task2_files() ...
  , 'start_event', 'head reappears' ...
  , 'stop_event', 'shoulder move' ...
  , 'look_back', 0 ...
  , 'look_ahead', 0 ...
  , 'is_parallel', true ...
  , 'pad_face_y', 0.05 ...
);

roi_sequence = sequence_outputs.roi_sequence';
rois = { 'face', 'boxl', 'boxr' };

[anticipatory_looks_to, labels] = jjtom_anticipatory_looks( roi_sequence, rois );

tbl = jjtom_anticipatory_looks_to_table( anticipatory_looks_to, labels );

if ( do_save )
  analysis_p = fullfile( jjtom.get_datadir('analyses'), dsp3.datedir, 'anticipatory', 'task2' );
  shared_utils.io.require_dir( analysis_p );
  
  dsp3.writetable( tbl, fullfile(analysis_p, 'anticipatory_look_info') );
end