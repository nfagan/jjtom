function face_roi = get_middle_face_roi_from_facelr(facel, facer)

min_x = facel(1);
max_x = facer(3);

min_y = facer(2);
max_y = facer(4);

w = max_x - min_x;

new_w = w * (1 / 3);

mid_x = (max_x + min_x) / 2;

min_x = mid_x - (new_w / 2);
max_x = mid_x + (new_w / 2);

% half_h = h/2;
% 
% min_y = min_y - half_h * params.pad_face_y;
% max_y = max_y + half_h * params.pad_face_y;

face_roi = [ min_x, min_y, max_x, max_y ];

end