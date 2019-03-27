function roi = pad_roi(roi, amount_x, amount_y)

w = roi(3) - roi(1);
h = roi(4) - roi(2);

pad_half_w = w * amount_x / 2;
pad_half_h = h * amount_y / 2;

roi(1) = roi(1) - pad_half_w;
roi(3) = roi(3) + pad_half_w;
roi(2) = roi(2) - pad_half_h;
roi(4) = roi(4) + pad_half_h;

end