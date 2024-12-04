function dotx = dote7(t,x)
dotx(1,1) = x(2,1) + 2*x(1,1)^2 + x(1,1)*x(2,1);
dotx(2,1) = -x(1,1) - x(2,1) +x(1,1)*x(2,1) + 3*x(2,1)^2;
