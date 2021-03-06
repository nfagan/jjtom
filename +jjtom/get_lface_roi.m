function roi = get_lface_roi(screen_dists, screen_consts, app_dists, app_consts, padding)

w = app_consts.face_width_cm / 2;
h = app_consts.face_height_cm;

app_h = app_consts.apparatus_height_cm;

xd = 0;
yd = app_h;
zd = app_consts.apparatus_depth_cm;

if ( nargin == 5 )
%   [xd, w] = jjtom.pad( xd, w, padding.x );
  [yd, h] = jjtom.pad( yd, h, padding.y );
end

roi = jjtom.get_roi( app_dists, screen_consts, screen_dists, xd, yd, zd, w, h );

end