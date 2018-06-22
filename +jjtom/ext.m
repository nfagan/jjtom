function s = ext(s, ends_with)
%   EXT -- Add extension if not present.
%
%     s = ... ext( S, '.mat' ) adds '.mat' to S if S does not already end
%     with '.mat'.
%
%     IN:
%       - `s` (char)
%       - `ends_with` (char)
%     OUT:
%       - `s` (char)
s = shared_utils.char.require_end( s, ends_with );
end