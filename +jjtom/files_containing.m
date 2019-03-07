function files = files_containing(files, containing)

if ( ~isempty(containing) )
  files = shared_utils.cell.containing( files, containing );
end

end