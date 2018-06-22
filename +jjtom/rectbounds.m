function ib = rectbounds(x, y, rect)
ib = x >= rect(1) & x <= rect(3) & y >= rect(2) & y <= rect(4);
end