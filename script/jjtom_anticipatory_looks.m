function [anticipatory_looks_to, labels] = jjtom_anticipatory_looks(roi_sequence, rois, check_each)

if ( nargin < 3 )
  check_each = 'id';
end

[labels, I] = keepeach( roi_sequence', check_each, find(roi_sequence, rois) );

anticipatory_looks_to = cell( numel(I), 1 );

for i = 1:numel(I)
  anticipatory_looks_to{i} = find_anticipatory_looks( roi_sequence, I{i} );
end

end

function [looks_to, next_index] = count_looks(roi_labels, looks_to, next_index)

n_events = numel( roi_labels );

if ( next_index > n_events || ~strcmp(roi_labels{next_index}, 'face') )
  return
end

ind = next_index + 1;

while ( ind <= n_events && strcmp(roi_labels{ind}, 'face') )
  ind = ind + 1;
end

if ( ind > n_events )
  return
end

last_label = roi_labels{ind};

if ( strcmp(last_label, 'boxl') || strcmp(last_label, 'boxr') )
  looks_to{end+1} = last_label;
end

[looks_to, next_index] = count_looks( roi_labels, looks_to, ind + 1 );

end

function looks_to = find_anticipatory_looks(roi_sequence, mask)

looks_to = count_looks( cellstr(roi_sequence, 'roi', mask), {}, 1 );

end