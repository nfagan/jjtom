function [counts, labs] = task2_box1(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'box1' );

is_box_left = find( labs, 'boxl' );

setcat( labs, 'roi', 'target-roi', is_box_left );

label_other_rois( labs );

prune( labs );

end

function label_other_rois(labs)

is_other_box = find( labs, 'boxr' );
setcat( labs, 'roi', 'other-box', is_other_box );

end