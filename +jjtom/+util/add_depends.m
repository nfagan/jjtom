
function add_depends(conf)

%   ADD_DEPENDS -- Add dependencies as defined in the config file.

if ( nargin < 1 || isempty(conf) )
  conf = jjtom.config.load();
else
  jjtom.util.assertions.assert__is_config( conf );
end

repos = mkcell( conf.DEPENDS.repositories );
repo_dir = conf.PATHS.repositories;

add_all( repo_dir, repos );

if ( isfield(conf.DEPENDS, 'others') )
  others = mkcell( conf.DEPENDS.others );
  
  add_all( '', others );
end

end

function add_all(repo_dir, depends)

for i = 1:numel(depends)
  try
    add_char_or_struct_field( repo_dir, depends{i} );
  catch err
    warning( err.message );
  end
end

end

function add_char_or_struct_field(repo_dir, p)
addpath( genpath(jjtom.util.get_depend_dir(repo_dir, p)) );
end

function c = mkcell(c)
if ( ~iscell(c) ), c = { c }; end
end