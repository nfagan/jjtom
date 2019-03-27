function [counts, labs] = task1_box2(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels', 'task-interval', 'box2' );

is_box2 = jjtom.task1_is_side_apple_enters( labs, 'boxl', 'boxr' );

setcat( labs, 'roi', 'target-roi', is_box2 );

label_other_rois( labs, is_box2 );

prune( labs );

end

function label_other_rois(labs, is_box2)

other_box_ind = find( ~trueat(labs, is_box2) );

other_box = find( labs, {'boxl', 'boxr'}, other_box_ind );

setcat( labs, 'roi', 'other-box', other_box );

end