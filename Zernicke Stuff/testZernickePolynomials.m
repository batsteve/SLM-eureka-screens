interval = linspace(-1, 1, 20);
[xx, yy] = ndgrid(interval, interval);
rr = sqrt(xx.^2 + yy.^2);
theta = atan2(yy, xx);
j = 47;
uu = ZPZernicke(j, rr, theta);
figure(1);
clf;
mesh(xx, yy, uu);