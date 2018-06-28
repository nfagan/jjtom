function I = get_apple_indices(labs)

I = [];

selectors = {
  {'boxl', 'apparatusl', 'left', 'consistent'},
  {'boxl', 'apparatusl', 'right', 'inconsistent'},
  {'boxr', 'apparatusr', 'right', 'consistent'},
  {'boxr', 'apparatusr', 'left', 'inconsistent'}
};

for j = 1:numel(selectors)
  I = union( I, find(labs, selectors{j}) );
end

end