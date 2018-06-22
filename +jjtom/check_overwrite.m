function tf = check_overwrite(fname, overwrite)
tf = shared_utils.io.fexists( fname );
if ( tf )
  if ( ~overwrite )
    [~, fileid] = fileparts( fname );
    fprintf( '\n Skipping "%s": file already exists.', fileid );
  else
    tf = false;
  end
end
end