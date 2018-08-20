function roi = get_face_roi(screen_dists, screen_consts, app_dists, app_consts, padding)

w = app_consts.face_width_cm;
h = app_consts.face_height_cm;

app_w = app_consts.apparatus_width_cm / 2;
app_h = app_consts.apparatus_height_cm;

xd = app_w - (w/2);
yd = app_h;
zd = app_consts.apparatus_depth_cm;

if ( nargin == 5 )
  [xd, w] = jjtom.pad( xd, w, padding.x );
  [yd, h] = jjtom.pad( yd, h, padding.y );
end

roi = jjtom.get_roi( app_dists, screen_consts, screen_dists, xd, yd, zd, w, h );

end