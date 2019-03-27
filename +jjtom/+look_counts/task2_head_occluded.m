function [counts, labs] = task2_head_occluded(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'head-occluded' );

is_face = find( labs, 'face' );

setcat( labs, 'roi', 'target-roi', is_face );

end