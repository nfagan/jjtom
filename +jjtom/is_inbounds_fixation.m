function ib_fixs = is_inbounds_fixation(fix_x, fix_y, rois)

ib_fixs = cell( numel(rois), 1 );

for i = 1:numel(rois)
  ib_fixs{i} = jjtom.rectbounds( fix_x, fix_y, rois{i} );
end

end