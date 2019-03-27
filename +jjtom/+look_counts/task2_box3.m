function [counts, labs] = task2_box3(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'box3' );

is_box3 = jjtom.task2_is_side_apple_enters2( labs, 'boxl', 'boxr' );

setcat( labs, 'roi', 'target-roi', is_box3 );

label_other_box( labs, is_box3 );

prune( labs );

end

function label_other_box(labs, is_box3)

is_box = find( labs, {'boxl', 'boxr'} );
is_other_box = setdiff( is_box, is_box3 );

setcat( labs, 'roi', 'other-box', is_other_box );

end