function ib_fixs = separate_apparatus_and_face_fixations(ib_fixs, roi_names)

apparatus_l = strcmp( roi_names, 'apparatusl' );
apparatus_r = strcmp( roi_names, 'apparatusr' );

face_l = strcmp( roi_names, 'facel' );
face_r = strcmp( roi_names, 'facer' );

assert( nnz(apparatus_l | apparatus_r | face_l | face_r) == 4 );

is_ib_face = ib_fixs{face_l} | ib_fixs{face_r};

% Remove fixations that overlap between face and apparatus
ib_fixs{apparatus_l}(is_ib_face) = false;
ib_fixs{apparatus_r}(is_ib_face) = false;

end