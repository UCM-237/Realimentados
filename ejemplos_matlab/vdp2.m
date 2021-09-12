function xdot = vdp2(t,x,m,C,L)
%funcion para representar las derivadas de la variable de estado de 
%la ecuacion de Van der Pol
%en este caso, pasamos los parametros de la ecuacion en lugar de definirlos
%dentro
%integrarlas con los integradores de matlab ej ode45
%definimos los parametros de la ecuacion

%m = 1; c = 0.5; k = 1;
xdot(1,1) = x(2);
xdot(2,1) = -x(1)/(L*C) - m/C*(x(1)^2-1)*x(2);