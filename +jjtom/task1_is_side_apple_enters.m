function is_box2 = task1_is_side_apple_enters(labs, left_roi, right_roi)

consistent = find( labs, 'consistent' );
inconsistent = find( labs, 'inconsistent' );

reach_left = find( labs, 'left' );
reach_right = find( labs, 'right' );

left_consistent = find( labs, left_roi, intersect(reach_left, consistent) );
right_consistent = find( labs, right_roi, intersect(reach_right, consistent) );
right_inconsistent = find( labs, right_roi, intersect(reach_left, inconsistent) );
left_inconsistent = find( labs, left_roi, intersect(reach_right, inconsistent) );

is_box2 = union( ...
    union(left_consistent, right_consistent) ...
  , union(left_inconsistent, right_inconsistent) ...
);

end