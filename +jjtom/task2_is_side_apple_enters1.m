function is_box2 = task2_is_side_apple_enters1(labs, left_roi, right_roi)

target_left = find( labs, 'target-left' );
target_right = find( labs, 'target-right' );

is_left = find( labs, left_roi, target_right );
is_right = find( labs, right_roi, target_left );

is_box2 = union( is_left, is_right );

end