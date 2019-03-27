function [counts, labs] = task2_box2(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels, 'task-interval', 'box2' );

expected = find( labs, 'expected' );
unexpected = find( labs, 'unexpected' );

target_left = find( labs, 'target-left' );
target_right = find( labs, 'target-right' );

left_expected = find( labs, 'boxr', intersect(target_left, expected) );
right_expected = find( labs, 'boxl', intersect(target_right, expected) );

left_unexpected = find( labs, 'boxr', intersect(target_left, unexpected) );
right_unexpected = find( labs, 'boxl', intersect(target_right, unexpected) );

is_box2 = union( ...
    union(left_expected, right_expected) ...
  , union(left_unexpected, right_unexpected) ...
);

setcat( labs, 'roi', 'target-roi', is_box2 );

end