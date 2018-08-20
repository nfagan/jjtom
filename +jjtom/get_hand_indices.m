function I = get_hand_indices(labs)

I = [];

selectors = {
  {'facel', 'boxl', 'apparatusl', 'left', 'consistent'},
  {'facer', 'boxr', 'apparatusr', 'right', 'consistent'},
  {'facel', 'boxl', 'apparatusl', 'left', 'inconsistent'},
  {'facer', 'boxr', 'apparatusr', 'right', 'inconsistent'}
};

for j = 1:numel(selectors)
  I = union( I, find(labs, selectors{j}) );
end

end