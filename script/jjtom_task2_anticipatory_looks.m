function jjtom_task2_anticipatory_looks(roi_sequence, varargin)

defaults.rois = { 'face', 'boxl', 'boxr' };

params = jjtom.parsestruct( defaults, varargin );

I = findall( roi_sequence, 'id', find(roi_sequence, params.rois) );

n_anticipatory_looks = zeros( numel(I), 1 );

for i = 1:numel(I)
  n_anticipatory_looks(i) = count_anticipatory_looks( roi_sequence, I{i} );
end

end

function [n_looks, next_index] = count_looks(roi_labels, n_looks, next_index)

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
  n_looks = n_looks + 1;
end

[n_looks, next_index] = count_looks( roi_labels, n_looks, ind + 1);

end

function n_looks = count_anticipatory_looks(roi_sequence, mask)

n_looks = count_looks( cellstr(roi_sequence, 'roi', mask), 0, 1 );

end