function [counts, labs] = task2_head_reappears(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'head-reappears' );

is_face = find( labs, 'face' );

setcat( labs, 'roi', 'target-roi', is_face );

label_boxes( labs );

prune( labs );

end

function label_boxes(labs)

is_box_apple_enters = jjtom.task2_is_side_apple_enters2( labs, 'boxl', 'boxr' );
is_other_box = setdiff( find(labs, {'boxl', 'boxr'}), is_box_apple_enters );

setcat( labs, 'roi', 'box-apple-enters', is_box_apple_enters );
setcat( labs, 'roi', 'other-box', is_other_box );

end