function dotx = ej5(t,x)
dotx(1,1) = x(2,1);
dotx(2,1) = -x(1,1) + x(2,1)*(x(1,1)^2 -1);