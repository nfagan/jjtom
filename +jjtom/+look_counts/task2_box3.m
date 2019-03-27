function [counts, labs] = task2_box3(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'box3' );

target_left = find( labs, {'boxl', 'target-left'} );
target_right = find( labs, {'boxr', 'target-right'} );

is_box3 = union( target_left, target_right );

setcat( labs, 'roi', 'target-roi', is_box3 );

end