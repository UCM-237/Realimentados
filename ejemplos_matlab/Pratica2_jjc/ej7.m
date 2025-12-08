function dotx = ej8(t,x,epsilon)
dotx(1,1) = x(2,1);
dotx(2,1) = -sin(x(1,1)) -epsilon * x(2,1);