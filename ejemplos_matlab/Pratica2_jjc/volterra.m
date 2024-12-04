function dotx = volterra(t,x,mu,tau)
dotx(1,1) = x(1,1) - x(1,1)* x(2,1) -mu * x(1,1)^2;
dotx(2,1) = x(1,1)*x(2,1) - x(2,1)-tau* x(2,1) *( x(1,1) - x(1,1)* x(2,1) -mu * x(1,1)^2);