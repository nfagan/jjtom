function roi = get_lapparatus_roi(screen_dists, screen_consts, app_dists, app_consts, padding, limit_y)

if ( nargin < 6 )
  limit_y = false;
end

xd = 0;
yd = 0;
zd = 0;

w = app_consts.apparatus_width_cm / 2;  % first half of apparatus
h = app_consts.apparatus_height_cm;

if ( false )
%   if ( nargin == 5)
  [xd, w] = jjtom.pad( xd, w, padding.x );
  [yd, h] = jjtom.pad( yd, h, padding.y );
end

roi = jjtom.get_roi( app_dists, screen_consts, screen_dists, xd, yd, zd, w, h );

if ( ~limit_y )
  %   no limit on y
  roi(2) = -Inf;
  roi(4) = Inf;
end

end