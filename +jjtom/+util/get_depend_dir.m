function s = get_depend_dir(repo_dir, p)

if ( isstruct(p) )
  s = fullfile( repo_dir, get_struct_p(p) );
else
  s = fullfile( repo_dir, p );
end

end

function s = get_struct_p(p)
s = p.name;
if ( isfield(p, 'subdir') ), s = fullfile( s, p.subdir ); end
end