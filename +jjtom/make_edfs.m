function make_edfs(varargin)

defaults = jjtom.get_common_make_defaults();

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;

edf_p = jjtom.get_datadir( 'edf', conf );
edfs = jjtom.get_datafiles( 'edf', conf, '.edf', params.files );

for i = 1:numel(edfs)
  shared_utils.general.progress( i, numel(edfs), mfilename );
  
  [~, edf_id] = fileparts( edfs{i} );
  
  output_fname = fullfile( edf_p, jjtom.ext(edf_id, '.mat') );
  
  if ( jjtom.check_overwrite(output_fname, params.overwrite) ), continue; end
  
  edf = Edf2Mat( edfs{i} );
  
  edf_file = struct();
  edf_file.fileid = edf_id;
  edf_file.params = params;
  edf_file.Samples = edf.Samples;
  edf_file.Events = edf.Events;
  
  save( output_fname, 'edf_file' );
end

end