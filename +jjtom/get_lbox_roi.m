function roi = get_lbox_roi(screen_dists, screen_consts, app_dists, app_consts, padding)

xd = app_dists.app_origin_to_lbox_left_cm;
yd = app_dists.app_origin_to_lbox_bottom_cm;
zd = app_dists.app_origin_to_lbox_front_cm;

w = app_consts.box_width_cm;
h = app_consts.box_height_cm;

if ( nargin == 5)
  [xd, w] = jjtom.pad( xd, w, padding.x );
  [yd, h] = jjtom.pad( yd, h, padding.y );
end

roi = jjtom.get_roi( app_dists, screen_consts, screen_dists, xd, yd, zd, w, h );

end