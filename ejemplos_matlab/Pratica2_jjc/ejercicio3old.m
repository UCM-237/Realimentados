%El modelo de Lor%creamos unas variables simbolicas 
syms x1 x2 x3 s;
%y unos parametros sigma y lambda tambien simbolicos
syms sigma lambda b;

%creamos las ecuaciones del sistema
f(1,1) = sigma*(x2-x1);
f(2,1) = (lambda-x3)*x1-x2;
f(3,1) = x1*x2-b*x3;

J = jacobian(f,[x1 x2 x3]);
%obtenemos los puntos en que se anulan las ecuaciones de estado, ya que
%dichos puntos son precisamente los puntos deequilibrio
[x10,x20,x30] = solve(f,[x1 x2 x3]);
X0 = [x10,x20,x30];
%valores numericos de los puntso de equilibrio
X0num = double(subs(X0,{sigma,lambda,b},{10,28,8/3}))


for i =1:size(X0,1)
    %sustituimos la solucion en la expresion del Jacobiano
    Je = subs(J,{x1,x2,x3},X0(i,:))
    Jenum = subs(Je,{sigma,lambda,b},{10,28,8/3})
    E = eig(Jenum)
    Enum = double(E) 
end

%EL tercer jacobiano es el que correspnde al punto de equilibrio de interes
%para el resto del problema. Reconstruimos empleando la ley de control
%sugerida
syms k
Jenumc = Jenum;
Jenumc(2,1) = Jenumc(2,1) - k
D = det(s*eye(length(X0(3,:))) - Jenumc) %ver que forma tiene mas que nada
%aplicar el criterio de routz - hurwotz a un polinomio de grado tres,
% a3x^3+a2*x^2+a1*x+a0 
%basta imponer la condición hasta parametro alpha1
% a3 > 0
% a2 > 0 cumple
% alpha1 = a1 - a3*a0/a2
% alpha2 =a0

a0 = 1440 + 80*k/3
a1 = 10*k + 304/3
a2 = 41/3
a3 = 1

alpha1 = a1 - a3*a0/a2
klim = double(solve(alpha1,k))
%el valor de klim fuerza que se cumpla el criterio para a0..

