function obj = repset(obj, cat, to)

%   REPSET -- Replicate and assign labels to full subset.
%
%     ... repset( A, C, TO ); where `A` is an fcat object, `C` is a
%     character vectory identifying a category in `A`, and `TO` is a cell
%     array of strings, replicates the contents of `A` N times, where N is
%     equal to the number of elements in `TO`. For each replication `i`, 
%     the contents of the category `C` will be set to `TO{i}`.
%
%     IN:
%       - `obj` (fcat)
%       - `cat` (char)
%       - `to` (cell array of strings, char)

if ( ~iscell(to) ), to = { to }; end

N = length( obj );
repmat( obj, numel(to) );

rowsi = 1:N;

for i = 1:numel(to)
  setcat( obj, cat, to{i}, rowsi + ((i-1)*N) );
end

end