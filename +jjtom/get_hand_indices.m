function I = get_hand_indices(labs)

I = [];

selectors = {
  {'boxl', 'apparatusl', 'left', 'consistent'},
  {'boxr', 'apparatusr', 'right', 'consistent'},
  {'boxl', 'apparatusl', 'left', 'inconsistent'},
  {'boxr', 'apparatusr', 'right', 'inconsistent'}
};

for j = 1:numel(selectors)
  I = union( I, find(labs, selectors{j}) );
end

end