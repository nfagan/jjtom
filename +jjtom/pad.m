function [x, v] = pad(x, v, amt)

x = x - (amt/2);
v = v + amt;

end