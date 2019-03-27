function roi = get_extended_fruit_roi_from_boxes(roi_file)

left_box = roi_file.rois.boxl;
right_box = roi_file.rois.boxr;

min_x = left_box(3);
max_x = right_box(1);

min_y = (left_box(2) + right_box(2)) / 2;
max_y = (left_box(4) + right_box(4)) / 2;

roi = [ min_x, min_y, max_x, max_y ];

end