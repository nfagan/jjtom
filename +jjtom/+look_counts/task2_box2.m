function [counts, labs] = task2_box2(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'box2' );

is_box2 = jjtom.task2_is_side_apple_enters1( labs, 'boxl', 'boxr' );

setcat( labs, 'roi', 'target-roi', is_box2 );

label_other_rois( labs, is_box2 );

prune( labs );

end

function label_other_rois(labs, is_box2)

is_box = find( labs, {'boxl', 'boxr'} );

other_box = setdiff( is_box, is_box2 );

setcat( labs, 'roi', 'other-box', other_box );

end