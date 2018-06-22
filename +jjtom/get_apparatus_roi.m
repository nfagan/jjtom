function roi = get_apparatus_roi(screen_dists, screen_consts, app_dists, app_consts, padding)

xd = 0;
yd = 0;
zd = 0;

w = app_consts.apparatus_width_cm;
h = app_consts.apparatus_height_cm;

if ( nargin == 5)
  [xd, w] = jjtom.pad( xd, w, padding.x );
  [yd, h] = jjtom.pad( yd, h, padding.y );
end

roi = jjtom.get_roi( app_dists, screen_consts, screen_dists, xd, yd, zd, w, h );

end