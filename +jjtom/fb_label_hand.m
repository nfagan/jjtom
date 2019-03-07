function [labs, is_look_to_hand] = fb_label_hand(labs, mask)

if ( nargin < 2 )
  mask = rowmask( labs );
end

left_roi_selectors = { 'apparatusl', 'facel' };
right_roi_selectors = { 'apparatusr', 'facer' };

hand_left_selectors = { 'KrLu', 'KrRe', 'CnLu', 'CnRe' };
hand_right_selectors = { 'KrRu', 'KrLe', 'CnRu', 'CnLe' };

is_look_to_hand_left = [];
for i = 1:numel(left_roi_selectors)
  use_selectors = cshorzcat( left_roi_selectors{i}, hand_left_selectors );  
  is_look_to_hand_left = union( is_look_to_hand_left, find(labs, use_selectors, mask) );
end

is_look_to_hand_right = [];
for i = 1:numel(right_roi_selectors)
  use_selectors = cshorzcat( right_roi_selectors{i}, hand_right_selectors );  
  is_look_to_hand_right = union( is_look_to_hand_right, find(labs, use_selectors, mask) );
end

% is_look_to_hand_right = find( labs, {'apparatusr', 'KrRu', 'KrLe', 'CnRu', 'CnLe'}, mask );
% is_look_to_hand_left = find( labs, {'apparatusl', 'KrLu', 'KrRe', 'CnLu', 'CnRe'}, mask );
is_look_to_hand = union( is_look_to_hand_left, is_look_to_hand_right );

setcat( labs, 'roi', 'hand', is_look_to_hand );

end