function [counts, labs] = task2_reach_box(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'reach-box' );

is_reach_box = jjtom.is_side_of_reach( labs, 'boxl', 'boxr' );

label_other_box( labs, is_reach_box );

setcat( labs, 'roi', 'target-roi', is_reach_box );

prune( labs );

end

function label_other_box(labs, is_reach_box)

is_box = find( labs, {'boxl', 'boxr'} );
is_other_box = setdiff( is_box, is_reach_box );

setcat( labs, 'roi', 'other-box', is_other_box );

end