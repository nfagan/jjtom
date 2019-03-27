function is_box3 = task2_is_side_apple_enters2(labs, left_roi, right_roi)

target_left = find( labs, 'target-left' );
target_right = find( labs, 'target-right' );

is_left = find( labs, left_roi, target_left );
is_right = find( labs, right_roi, target_right );

is_box3 = union( is_left, is_right );

end