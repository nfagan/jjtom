function is_reach = is_side_of_reach(labs, left_roi, right_roi)

expected = find( labs, 'expected' );
unexpected = find( labs, 'unexpected' );

target_left = find( labs, 'target-left' );
target_right = find( labs, 'target-right' );

left_expected = find( labs, right_roi, intersect(target_left, expected) );
right_expected = find( labs, left_roi, intersect(target_right, expected) );

left_unexpected = find( labs, left_roi, intersect(target_left, unexpected) );
right_unexpected = find( labs, right_roi, intersect(target_right, unexpected) );

is_reach = union( ...
    union(left_expected, right_expected) ...
  , union(left_unexpected, right_unexpected) ...
);

end