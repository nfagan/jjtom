function [counts, labs] = task1_reach_box(count_outputs)

counts = count_outputs.fixation_counts;
labs = addsetcat( count_outputs.labels', 'task-interval', 'reach-box' );

% Remove face
not_face = findnone( labs, 'face' );
keep( labs, not_face );
counts = counts(not_face);

consistent = find( labs, 'consistent' );
inconsistent = find( labs, 'inconsistent' );

reach_left = find( labs, 'left' );
reach_right = find( labs, 'right' );

left_consistent = find( labs, 'boxl', intersect(reach_left, consistent) );
right_consistent = find( labs, 'boxr', intersect(reach_right, consistent) );
right_inconsistent = find( labs, 'boxr', intersect(reach_right, inconsistent) );
left_inconsistent = find( labs, 'boxl', intersect(reach_left, inconsistent) );

is_reach_box = union( ...
    union(left_consistent, right_consistent) ...
  , union(left_inconsistent, right_inconsistent) ...
);

setcat( labs, 'roi', 'target-roi', is_reach_box );

label_other_box( labs, is_reach_box );

is_face_left = find( labs, 'facel', reach_left );
is_face_right = find( labs, 'facer', reach_right );

setcat( labs, 'roi', 'face', union(is_face_left, is_face_right) );

prune( labs );

end

function label_other_box(labs, is_reach_box)

other_box_ind = find( ~trueat(labs, is_reach_box) );

other_box = find( labs, {'boxl', 'boxr'}, other_box_ind );

setcat( labs, 'roi', 'other-box', other_box );

end