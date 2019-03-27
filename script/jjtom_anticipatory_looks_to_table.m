function tbl = jjtom_anticipatory_looks_to_table(anticipatory_looks_to, labels)

assert_ispair( anticipatory_looks_to, labels );

tbl_inputs = cell( numel(anticipatory_looks_to), 1 );
var_names = { 'Look_1' };

for i = 1:numel(anticipatory_looks_to)
  current_looks_to = anticipatory_looks_to{i};
  
  if ( numel(current_looks_to) > numel(var_names) )
    var_names{end+1} = sprintf( 'Look_%d', numel(current_looks_to) );
  end
  
  if ( isempty(current_looks_to) )
    tbl_inputs{i, 1:end} = [];
  else
    for j = 1:numel(current_looks_to)
      tbl_inputs{i, j} = current_looks_to{j};
    end
  end
end

tbl = table( tbl_inputs, 'variablenames', var_names );
tbl.Properties.RowNames = cellstr( labels, 'id' );

end