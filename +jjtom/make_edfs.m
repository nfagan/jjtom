function make_edfs()

edf_p = jjtom.get_datadir( 'edf' );
output_p = edf_p;

edfs = shared_utils.io.dirnames( edf_p, '.edf' );

for i = 1:numel(edfs)
  shared_utils.general.progress( i, numel(edfs), mfilename );
  
  edf_id = edfs{i}(1:end-4);
  
  output_fname = fullfile( output_p, [edf_id, '.mat'] );
  
  if ( shared_utils.io.fexists(output_fname) )
    continue;
  end
  
  edf = Edf2Mat( fullfile(edf_p, edfs{i}) );
  
  edf_struct = struct();
  edf_struct.Samples = edf.Samples;
  edf_struct.Events = edf.Events;
  edf_struct.fileid = edf_id;
  
  save( output_fname, 'edf_struct' );
end

end