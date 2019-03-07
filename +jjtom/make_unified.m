function make_unified(varargin)

defaults = jjtom.get_common_make_defaults();

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;

un_p = jjtom.get_datadir( 'unified', conf );
indices_p = jjtom.get_datadir( 'corrective_event_indices', conf );

meta_mats = jjtom.get_datafiles( 'meta', conf, {'.mat', '.json'}, params.files );

for i = 1:numel(meta_mats)
  shared_utils.general.progress( i, numel(meta_mats), mfilename );
  
  [~, fileid] = fileparts( meta_mats{i} );
  
  output_fname = fullfile( un_p, jjtom.ext(fileid, '.mat') );
  event_indices_filename = fullfile( indices_p, jjtom.ext(fileid, '.json') );
  
  if ( jjtom.check_overwrite(output_fname, params.overwrite) ), continue; end
  
  has_event_indices = false;
  
  if ( shared_utils.io.fexists(event_indices_filename) )
    event_indices_file = jjtom.fload( event_indices_filename );
    event_indices = event_indices_file.events;
    has_event_indices = true;
  end
  
  meta = jjtom.fload( meta_mats{i} );
  meta.id = fileid;
  
  meta_file = struct();
  meta_file.fileid = fileid;
  meta_file.meta = meta;
  
  if ( has_event_indices )
    meta_file.event_indices = event_indices;    
  end
  
  shared_utils.io.require_dir( un_p );
  
  save( output_fname, 'meta_file' );  
end

end