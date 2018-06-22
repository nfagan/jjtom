function make_unified(varargin)

defaults = jjtom.get_common_make_defaults();

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;

un_p = jjtom.get_datadir( 'unified' );

meta_mats = jjtom.get_datafiles( 'meta', conf, {'.mat', '.json'}, params.files );

for i = 1:numel(meta_mats)
  shared_utils.general.progress( i, numel(meta_mats), mfilename );
  
  [~, fileid] = fileparts( meta_mats{i} );
  
  output_fname = fullfile( un_p, jjtom.ext(fileid, '.mat') );
  
  if ( jjtom.check_overwrite(output_fname, params.overwrite) ), continue; end
  
  meta = jjtom.fload( meta_mats{i} );
  
  meta_file = struct();
  meta_file.fileid = fileid;
  meta_file.meta = meta;
  
  shared_utils.io.require_dir( un_p );
  
  save( output_fname, 'meta_file' );  
end

end