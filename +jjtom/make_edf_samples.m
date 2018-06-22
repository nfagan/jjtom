function make_edf_samples(varargin)

defaults = jjtom.get_common_make_defaults();

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;

isd = params.input_subdir;
osd = params.output_subdir;

edf_p = jjtom.get_datadir( fullfile('edf/samples', osd), conf );
edfs = jjtom.get_datafiles( fullfile('edf', isd), conf, '.mat', params.files );

for i = 1:numel(edfs)
  shared_utils.general.progress( i, numel(edfs), mfilename );
  
  edf_file = shared_utils.io.fload( edfs{i} );
  edf_id = edf_file.fileid;
  
  output_fname = fullfile( edf_p, jjtom.ext(edf_id, '.mat') );
  
  if ( jjtom.check_overwrite(output_fname, params.overwrite) ), continue; end
  
  samples_file = struct();
  samples_file.params = params;
  samples_file.fileid = edf_id;
  samples_file.t = edf_file.Samples.time;
  samples_file.x = edf_file.Samples.posX;
  samples_file.y = edf_file.Samples.posY;
  
  shared_utils.io.require_dir( edf_p );
  save( output_fname, 'samples_file' );
end

end