function conf = tmp_setdataroot(p, conf)

%   TMP_SETDATAROOT -- Set root data directory, without saving.
%
%     conf = ... tmp_setdataroot( p ); returns the config file `conf` whose
%     root data directory is set to `p`. `conf` is initially loaded from 
%     disk, and is not overwritten.
%
%     conf = ... tmp_setdataroot( p, conf ); updates the root data
%     directory of `conf`, instead of the saved config file.
%
%     See also jjtom.config.load
%
%     IN:
%       - `p` (char)
%       - `conf` (struct) |OPTIONAL|
%     OUT:
%       - `conf` (struct)

if ( nargin < 2 || isempty(conf) )
  conf = jjtom.config.load();
else
  jjtom.util.assertions.assert__is_config( conf );
end

validateattributes( p, {'char'}, {'scalartext'}, mfilename, 'root data path' );

conf.PATHS.data_root = p;

end