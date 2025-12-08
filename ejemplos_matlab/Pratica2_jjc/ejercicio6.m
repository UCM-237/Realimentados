clear all
%close all
%creamos unas variables simbolicas 
syms x1 x2 a b real 
syms s

%definimos las ecuaciones del sistema
f(1,1) = x2 + 2*x1^2+x1*x2
f(2,1) = -x1 - x2 + x1*x2 + 3*x2^2

%Calculamos el Jacobiano
J = jacobian(f,[x1 x2])
%obtenemos los puntos en que se anulan las ecuaciones de estado, ya que
%dichos puntos son precisamente los puntos deequilibrio
[x10,x20] = solve(f,[x1 x2])
X0 = [x10,x20]
%calculamos ahora resultados para todos los puntos de equilibrio
%encontrados

for i =1:size(X0,1)
    %sustituimos la solucion en la expresion del Jacobiano
    Je = subs(J,{x1,x2},X0(i,:))
    E = double(eig(Je))
    %calculamos el p carcateristico
    
    D = det(s*eye(length(X0(i,:))) - Je) %ver que forma tiene mas que nada 
end

%solo (0,0) es estable, asi que solo tiene sentido buscar estabilidad en
%torno a este punto...
Je = double(subs(J,{x1,x2},X0(1,:)))
Q = [1 0;0 1]
P = lyap(Je',Q)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%La funcion de lyapunov es entonces
V = [x1 x2] * P * [x1;x2]
%para aplicarla al sistema no lineal
V = simplify(V)
grV = gradient(V)
dotV = simplify(grV'*f)
% Vamos a dibujar el paraboloide
x1p = linspace(-0.25,0.25,20);
x2p = x1p;
[x1mp,x2mp] = meshgrid(x1p,x2p);
zm = 3*(x1mp.^2)/2 +x1mp.*x2mp + x2mp.^2;
surf(x1mp,x2mp,zm)
hold on
% y el plano x1+x =1/6
x = linspace(0,1/6,5)
y = 1/6-x
xm = [x;x;x;x;x;x;x;x]
ym = [y;y;y;y;y;y;y;y]
z = [-0.1 -0.05 0 0.05 0.1, 0.15 0.2 0.25]
zm = [z;z;z;z;z]'
mesh(xm,ym,zm)
xlabel('x')
ylabel('y')
plot3(x,y,5/216*ones(size(x)))
%tenemos que imponer la condicion de que los puntos de inicio no superen el
%valor de V correspondiente al punto mas bajo del corte de la funcion de
%Lyapunov con el plano vertical x2 = 1/6 -x1. Este plano marca el limite a
%partir del cual la derivada de Lyapunov deja de ser negativa... de este
%modo, obtenemos una cuenca de atraccion para el punto fijo (0,0) asociada
%a la funcion de liapunov empleada
%pintamos la curva famosa
 x1cu = linspace(-sqrt(4/216),sqrt(4/216),200);
 x2cu1 = (-x1cu+sqrt(20/216-5*(x1cu).^2))/2; % mitad
 x2cu2 = (-x1cu-sqrt(20/216-5*(x1cu).^2))/2; %otra mitad
 hold on
 plot3(x1cu,x2cu1,5/216*ones(size(x1cu)),'w')
 plot3(x1cu,x2cu2,5/216*ones(size(x1cu)),'w')
 
