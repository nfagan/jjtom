function make_edf_events(varargin)

defaults = jjtom.get_common_make_defaults();

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;

isd = params.input_subdir;
osd = params.output_subdir;

edf_p = jjtom.get_datadir( fullfile('edf/events', osd), conf );
edfs = jjtom.get_datafiles( fullfile('edf', isd), conf, '.mat', params.files );

for i = 1:numel(edfs)
  shared_utils.general.progress( i, numel(edfs), mfilename );
  
  edf_file = shared_utils.io.fload( edfs{i} );
  edf_id = edf_file.fileid;
  
  output_fname = fullfile( edf_p, jjtom.ext(edf_id, '.mat') );
  
  if ( jjtom.check_overwrite(output_fname, params.overwrite) ), continue; end
  
  events_file = struct();
  events_file.params = params;
  events_file.fileid = edf_id;
  events_file.fix_start = edf_file.Events.Efix.start;
  events_file.fix_stop = edf_file.Events.Efix.end;
  events_file.fix_x = edf_file.Events.Efix.posX;
  events_file.fix_y = edf_file.Events.Efix.posY;
  events_file.pupil = edf_file.Events.Efix.pupilSize;
  
  shared_utils.io.require_dir( edf_p );
  save( output_fname, 'events_file' );
end

end