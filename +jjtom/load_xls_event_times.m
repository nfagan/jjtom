function decomposed = load_xls_event_times(varargin)

defaults = struct();
defaults.config = jjtom.config.load();
defaults.xls_filename = 'ToMVideoCodingExp1andExp2_just_times.xlsx';

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;
xls_filename = params.xls_filename;

xls_file = fullfile( jjtom.get_datadir('xls', conf), xls_filename );

[~, ~, xls_raw] = xlsread( xls_file );

decomposed = decompose_xls( xls_raw );

end

function out = decompose_xls(xls_raw)

header = xls_raw(1, :);
rest = xls_raw(2:end, :);

not_missing_header = ~is_nan_in_cell( header );
not_missing_header_inds = find( not_missing_header );

ok_header = header(not_missing_header);

edf_id_ind = find1_in_header( ok_header, 'edf' );

remaining_events = setdiff( not_missing_header_inds, edf_id_ind );

edf_ids = rest(:, not_missing_header_inds(edf_id_ind));

non_nan_id = find( ~is_nan_in_cell(edf_ids) );

reformatted_ids = cell( numel(non_nan_id), 1 );
reformatted_times = nan( numel(non_nan_id), numel(remaining_events) );

for i = 1:numel(non_nan_id)
  non_nan_row = non_nan_id(i);
  
  reformatted_ids{i} = edf_ids{non_nan_row};
  
  for j = 1:numel(remaining_events)
    str_time = rest{non_nan_row, not_missing_header_inds(remaining_events(j))};
    
    if ( isnan(str_time) )
      continue;
    end
    
    secs = parse_seconds( str_time );
    
    reformatted_times(i, j) = secs;
  end
end

event_names = header(not_missing_header_inds(remaining_events));

out = struct();
out.file_ids = reformatted_ids;
out.event_times = reformatted_times;
out.event_key = event_names;

end


function has_contents = assert1_in_header(header_ind, kind)

has_contents = cellfun( @(x) ~isempty(x), header_ind );
has_one = nnz( has_contents ) == 1;

assert( has_one, 'Expected 1 "%s" in the header; instead there were %d.' ...
  , kind, nnz(has_contents) );

end

function ind = find1_in_header(header, val)

inds = strfind( header, val );

contents = assert1_in_header( inds, val );

ind = find( contents );

end

function tf = is_nan_in_cell(c)

tf = cellfun( @(x) isa(x, 'double') && isnan(x), c );

end

function t = parse_seconds(str)

minute_ind = strfind( str, ':' );
ms_ind = strfind( str, '.' );

% '03:08.926'
assert( minute_ind == 3 && ms_ind == 6 );

minutes = str2double( str(1:minute_ind-1) );
s = str2double( str(minute_ind+1:ms_ind-1) );
ms = str2double( str(ms_ind:end) ); % leave period -> floating point

t = (minutes * 60) + s + ms;

end