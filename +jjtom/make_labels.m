function make_labels(varargin)

defaults = jjtom.get_common_make_defaults();

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;

un_mats = jjtom.get_datafiles( 'unified', conf, '.mat', params.files );
lab_p = jjtom.get_datadir( 'labels', conf );

for i = 1:numel(un_mats)
  shared_utils.general.progress( i, numel(un_mats), mfilename );
  
  un_file = jjtom.fload( un_mats{i} );
  
  output_fname = fullfile( lab_p, jjtom.ext(un_file.fileid, '.mat') );
  
  if ( jjtom.check_overwrite(output_fname, params.overwrite) ), continue; end
  
  labs = struct2cell( un_file.meta );
  cats = fieldnames( un_file.meta );
  
  if ( any(strcmp(cats, 'target_direction')) )
    labs = relabel_directions( cats, labs );
  end
  
  label_file = struct();
  label_file.fileid = un_file.fileid;
  label_file.labels = labs(:)';
  label_file.categories = cats(:)';
  
  shared_utils.io.require_dir( lab_p );
  
  save( output_fname, 'label_file' );  
end

end

function labs = relabel_directions(cats, labels)

is_target_dir = strcmp( cats, 'target_direction' );
is_reach_dir = strcmp( cats, 'reach_direction' );

labs = labels;

labs(is_target_dir) = cellfun( @(x) sprintf('target-%s', x), labels(is_target_dir), 'un', 0 );
labs(is_reach_dir) = cellfun( @(x) sprintf('reach-%s', x), labels(is_reach_dir), 'un', 0 );

end