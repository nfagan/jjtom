function map = get_event_map()

% 1 - occluder-down-1
% 2 - reach-right-box
% 3 - occluder-down-2
% 4 - look-at-fruit
% 5 - occluder-down-3
% 6 - test-reach

map = containers.Map( 'keytype', 'double', 'valuetype', 'char' );

map(1) = 'od-1';
map(2) = 'right-reach';
map(3) = 'od-2';
map(4) = 'look-fruit';
map(5) = 'od-3';
map(6) = 'test-reach';

end