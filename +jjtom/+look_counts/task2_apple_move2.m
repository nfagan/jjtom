function [counts, labs] = task2_apple_move2(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'apple-move2' );

is_fruit = find( labs, 'middle_fruit' );

setcat( labs, 'roi', 'target-roi', is_fruit );

label_boxes( labs );

prune( labs );

end

function label_boxes(labs)

is_box_apple_enters = jjtom.task2_is_side_apple_enters2( labs, 'boxl', 'boxr' );
is_other_box = setdiff( find(labs, {'boxl', 'boxr'}), is_box_apple_enters );

setcat( labs, 'roi', 'box-apple-enters', is_box_apple_enters );
setcat( labs, 'roi', 'other-box', is_other_box );

end