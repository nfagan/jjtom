function f = fload(mat_or_json)

if ( shared_utils.char.ends_with(mat_or_json, '.json') )
  f = jsondecode( fileread(mat_or_json) );
else
  f = shared_utils.io.fload( mat_or_json );
end

end