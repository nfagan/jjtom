function [counts, labs] = task2_box1(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'box1' );

is_box_left = find( labs, 'boxl' );

setcat( labs, 'roi', 'target-roi', is_box_left );

end