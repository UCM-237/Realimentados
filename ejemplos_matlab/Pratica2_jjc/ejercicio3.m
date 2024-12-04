%caotico de rosler
clear all
close all
%creamos variables simbolicas
syms x1 x2 x3 s
%y tambien parametros simbolicos
syms a b c

% creamos el campo vectorial de modelo
f(1,1) = x1 -x1*x2 -x3
f(2,1) = x1^2 -a*x2
f(3,1) =b*x1 -c*x3

%buscamos los puntos sigulares en general

[x01, x02, x03] = solve(f,x1,x2,x3)
x0 = [x01,x02,x03]

%linealizamos en torno a los puntos singulares
%calculamos el jacobiano
J = jacobian(f,[x1,x2,x3])

%sustitimos para los puntos singulares y obtenemos los autovalores
for i = 1:size(x0,1)
    Je = subs(J,[x1,x2,x3],x0(i,:))
    lambda(:,i) = eig(Je)
    D = det(eye(3)*s-Je)
    D = collect(D)
end
%las expresiones son terribles... Sustituimos para los valores sugeridos
%lo hacemos antes?
fn = subs(f,[a,b,c],[0.1,0.1,14])
%buscamos los puntos singulares
[x01, x02, x03] = solve(fn,x1,x2,x3)
x0 = [x01,x02,x03]
Jn = jacobian(fn,[x1,x2,x3])

%sustitimos para los puntos singulares y obtenemos los autovalores
for i = 1:size(x0,1)
    Jen = subs(Jn,[x1,x2,x3],x0(i,:))
    lambdae(:,i) = eig(Jen) %(autovalores guardados por columnas ojo)
end
 
%convertimos autovalores y puntos en valores numericos
lnum = double(lambdae)
x0n = double(x0)

%podemos ahora simular que pasa si empezamos cerca del punto inestable..
%deberia irse a alguno de sus puntos de equilibrio amigos...

% x0n =
% 
%          0         0         0
%    -0.3151    0.9929   -0.0023
%     0.3151    0.9929    0.0023
plot3(x0n(1,1),x0n(1,2),x0n(1,3),'k^')
hold on
plot3(x0n(2,1),x0n(2,2),x0n(2,3),'^')
plot3(x0n(3,1),x0n(3,2),x0n(3,3),'r^')

xini = [0.01;0.01;1];
param = [0.1,0.1,14];
parametros = odeset('AbsTol',1e-9)
[t,x] = ode45(@(t,x)rossler(t,x,param),[0,40],xini,parametros);
plot3(x(:,1),x(:,2),x(:,3))
plot3(xini(1),xini(2),xini(3),'ob')

xini = [-0.01;-0.01;-1];
[t,x] = ode45(@(t,x)rossler(t,x,param),[0,40],xini,parametros);
plot3(x(:,1),x(:,2),x(:,3),'r')
plot3(xini(1),xini(2),xini(3),'or')

