function labs = fb_label_apple(labs, mask)

if ( nargin < 2 )
  mask = rowmask( labs );
end

is_look_to_apple_right = find( labs, {'apparatusr', 'KrRe', 'KrRu', 'CnRe', 'CnRu'}, mask );
is_look_to_apple_left = find( labs, {'apparatusl', 'KrLe', 'KrLu', 'CnLe', 'CnLu'}, mask );
is_look_to_apple = union( is_look_to_apple_left, is_look_to_apple_right );

setcat( labs, 'roi', 'apple', is_look_to_apple );

end