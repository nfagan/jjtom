function [counts, labs] = task1_box2(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels', 'task-interval', 'box2' );

consistent = find( labs, 'consistent' );
inconsistent = find( labs, 'inconsistent' );

reach_left = find( labs, 'left' );
reach_right = find( labs, 'right' );

left_consistent = find( labs, 'boxl', intersect(reach_left, consistent) );
right_consistent = find( labs, 'boxr', intersect(reach_right, consistent) );
right_inconsistent = find( labs, 'boxr', intersect(reach_left, inconsistent) );
left_inconsistent = find( labs, 'boxl', intersect(reach_right, inconsistent) );

is_box2 = union( ...
    union(left_consistent, right_consistent) ...
  , union(left_inconsistent, right_inconsistent) ...
);

setcat( labs, 'roi', 'target-roi', is_box2 );

label_other_rois( labs, is_box2 );

prune( labs );

end

function label_other_rois(labs, is_box2)

other_box_ind = find( ~trueat(labs, is_box2) );

other_box = find( labs, {'boxl', 'boxr'}, other_box_ind );

setcat( labs, 'roi', 'other-box', other_box );

end