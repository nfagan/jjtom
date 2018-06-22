function x = load1(kind, name, conf)

if ( nargin < 2 ), name = ''; end

if ( nargin < 3 || isempty(conf) )
  conf = jjtom.config.load(); 
else
  jjtom.util.assertions.assert__is_config( conf );
end

datadir = jjtom.get_datadir( kind, conf );

mats = shared_utils.io.find( datadir, '.mat' );

x = [];

if ( numel(mats) == 0 ), return; end

if ( isempty(name) )
  x = shared_utils.io.fload( mats{1} );
  return;
end

mats = shared_utils.cell.containing( mats, name );

if ( isempty(mats) ), return; end

x = shared_utils.io.fload( mats{1} );

end