function roi = get_rapparatus_roi(screen_dists, screen_consts, app_dists, app_consts, padding)

w = app_consts.apparatus_width_cm / 2;  % 2nd half of apparatus
h = app_consts.apparatus_height_cm;

xd = w;
yd = 0;
zd = 0;

if ( false )
%   if ( nargin == 5)
  [xd, w] = jjtom.pad( xd, w, padding.x );
  [yd, h] = jjtom.pad( yd, h, padding.y );
end

roi = jjtom.get_roi( app_dists, screen_consts, screen_dists, xd, yd, zd, w, h );

%   no limit on y
roi(2) = -Inf;
roi(4) = Inf;

end