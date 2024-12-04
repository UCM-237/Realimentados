function xdot =ej1a(t,x)
xdot(1,1) = x(2);
xdot(2,1) = -x(1)+x(2)*(1-x(2)^2);