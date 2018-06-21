function p = get_datadir(p, conf)

if ( nargin < 2 || isempty(conf) )
  conf = jjtom.config.load();
end

p = fullfile( conf.PATHS.data_root, p );

end