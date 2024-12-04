%creamos variables simbolicas
syms x1 x2 gamma real
%definimos las ecuaciones del sistema
f(1,1) = x2
f(2,1) = -x1^3 - gamma*x2
%obtenemos puntos de equilibrio
[x10,x20] = solve(f,[x1 x2])
X0 = [x10,x20]
%definimos V,
%ojo en el enunciado se propone usar x1^2+x2^2 pero el resultado es
%casi imposible de analizar....
V =x1^4/4+x2^2/2
grv = gradient(V)
vdot = grv'*f
%aplicar krasosky-lasalle