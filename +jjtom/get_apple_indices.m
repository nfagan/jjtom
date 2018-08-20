function I = get_apple_indices(labs)

I = [];

selectors = {
  {'facel', 'boxl', 'apparatusl', 'left', 'consistent'},
  {'facel', 'boxl', 'apparatusl', 'right', 'inconsistent'},
  {'facer', 'boxr', 'apparatusr', 'right', 'consistent'},
  {'facer', 'boxr', 'apparatusr', 'left', 'inconsistent'}
};

for j = 1:numel(selectors)
  I = union( I, find(labs, selectors{j}) );
end

end