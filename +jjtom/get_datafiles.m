function files = get_datafiles(p, conf, ext, containing)

if ( nargin < 4 ), containing = []; end
if ( nargin < 3 || isempty(ext) ), ext = '.mat'; end

if ( nargin < 2 || isempty(conf) )
  conf = jjtom.config.load();
else
  jjtom.util.assertions.assert__is_config( conf );
end

p = jjtom.get_datadir( p, conf );

if ( ~iscell(ext) ), ext = { ext }; end

files = {};

for i = 1:numel(ext)
  files = [ files, shared_utils.io.find(p, ext{i}) ];
end

if ( ~isempty(containing) )
  files = shared_utils.cell.containing( files, containing );
end

files = files( ~cellfun(@remove_if_leading_dot, files) );

end

function x = remove_if_leading_dot(file)

[~, name] = fileparts( file );

x = isempty(name) || strcmp( name(1), '.' );

end