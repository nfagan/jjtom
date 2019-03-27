function [counts, labs] = task2_apple_move2(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'apple-move2' );

is_fruit = find( labs, 'middle_fruit' );

setcat( labs, 'roi', 'target-roi', is_fruit );

end