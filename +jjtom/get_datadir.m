function p = get_datadir(p, conf)

if ( nargin < 1 ), p = ''; end
if ( nargin < 2 || isempty(conf) )
  conf = jjtom.config.load(); 
else
  jjtom.util.assertions.assert__is_config( conf );
end

p = fullfile( conf.PATHS.data_root, p );

end