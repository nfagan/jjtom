
function conf = create(do_save)

%   CREATE -- Create the config file. 
%
%     Define editable properties of the config file here.
%
%     IN:
%       - `do_save` (logical) -- Indicate whether to save the created
%         config file. Default is `false`

if ( nargin < 1 ), do_save = false; end

const = jjtom.config.constants();

conf = struct();

%   ID
conf.(const.config_id) = true;

%   PATHS
PATHS = struct();
PATHS.repositories = '';
PATHS.data_root = '';

%   DEPENDENCIES
DEPENDS = struct();
DEPENDS.repositories = { ...
    mkdepend('shared_utils', 'https://github.com/nfagan/shared_utils') ...
  , mkdepend('categorical', 'https://github.com/nfagan/categorical', 'api/matlab') ...
};

%   EXPORT
conf.PATHS = PATHS;
conf.DEPENDS = DEPENDS;

if ( do_save )
  jjtom.config.save( conf );
end

end

function s = mkdepend(name, src, subdir)

s = struct();
s.name = name;
s.src = src;

if ( nargin == 3 ), s.subdir = subdir; end

end