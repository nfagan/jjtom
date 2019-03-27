function [counts, labs] = task2_apple_move(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'apple-move' );

is_fruit = find( labs, 'middle_fruit' );

setcat( labs, 'roi', 'target-roi', is_fruit );

end