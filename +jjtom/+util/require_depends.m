function require_depends(conf)

%   REQUIRE_DEPENDS -- Install dependencies, if not already installed.

if ( nargin < 1 || isempty(conf) )
  conf = jjtom.config.load();
else
  jjtom.util.assertions.assert__is_config( conf );
end

assert( ~ispc(), 'Dependencies can currently only be required on OSX and Linux.' );
assert( hasgit(), 'Installation requires `git`. Search google for `install git`.' );

repodir = conf.PATHS.repositories;
repos = mkcell( conf.DEPENDS.repositories );

if ( isempty(repodir) ), repodir = jjtom.util.get_repo_dir(); end

installdirs = percell( @(x) jjtom.util.get_depend_dir(repodir, x), repos );
sources = percell( @get_src, repos );

can_require_ind = cellfun( @can_require_depend, repos );
already_exists_ind = cellfun( @direxists, installdirs );

reqdir( repodir );

for i = 1:numel(sources)
  repo = repos{i};
  src = sources{i};
  can_req = can_require_ind(i);
  already_exists = already_exists_ind(i);
  
  if ( ~can_req )
    fprintf( '\n Skipping "%s" because it is improperly formatted. See jjtom.config.create.', repo );
    continue;
  end
  
  if ( already_exists )
    fprintf( '\n Skipping "%s" because it already exists.', repo );
    continue;
  end
  
  clone_depend( src, repodir );
end

end

function clone_depend(src, outer)

fprintf( '\n Attempting to access "%s"\n\n', src );

current = cd();

cmd = get_clone_cmd( src );

try
  cd( outer );
  
  [res, msg] = system( cmd );
  
  disp( msg );
  
  if ( res ~= 0 )
    error( 'Cloning failed with above message.' );
  end
  
catch err
  warning( err.message );
end

cd( current );

end

function s = get_clone_cmd(src)
s = sprintf( 'git clone %s', src );
end

function tf = hasgit()
tf = false;

if ( isunix() )
  [res, msg] = system( 'which git' );
  tf = res == 0 && ~isempty( msg );
else
  warning( 'Platform "%s" not yet implemented.', computer );
end
end

function c = percell(func, c)
c = cellfun( func, c, 'un', 0 );
end

function reqdir(p)
if ( ~direxists(p) ), mkdir(p); end
end

function tf = direxists(p)
tf = exist( p, 'dir' ) == 7;
end

function s = get_src(p)
s = '';
if ( can_require_depend(p) ), s = p.src; end
end

function tf = can_require_depend(p)
tf = isstruct( p ) && isfield( p, 'src' );
end

function c = mkcell(c)
if ( ~iscell(c) ), c = { c }; end
end