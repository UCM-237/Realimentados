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
grV = gradient(V)
dotV = simplify(grV'*f)
xjx = [x1,x2]*(P)*[x1;x2]
xjxs = expand(xjx)
%vamos a ver que region nos define...
xn1 = -1:0.1:1;
xn2 = xn1
[xnm1 xnm2] = meshgrid(xn1,xn2);
for i = 1:length(xn1)
    for j = 1:length(xn2)
        h = subs(xjxs,[x1,x2],[xn1(i),xn2(j)]);
        xjxn(j,i) = double(h); %el meshgrid me obliga a meterlo al reves..
        %tiene que ver con la colocación de los valores en xnm... las x se
        %repiten for filas, asi que al calcular en el bucle hay que
        %guardarlo traspuesto...
    end
end
[c,h] = contour(xnm1,xnm2,xjxn,-0.1:0.005:0.1)
clabel(c,h)
hold on
%tenemos que imponer la condicion de que los puntos de inicio no superen el
%valor de V correspondiente al punto mas bajo del corte de la funcion de
%Lyapunov con el plano vertical x2 = 1/6 -x1. Este plano marca el limite a
%partir del cual la derivada de Lyapunov deja de ser negativa... de este
%modo, obtenemos una cuenca de atraccion para el punto fijo (0,0) asociada
%a la funcion de liapunov empleada
%pintamos la curva famosa
 x1cu = linspace(-sqrt(4/216),sqrt(4/216),200);
 x2cu1 = (-x1cu+sqrt(20/216-5*(x1cu).^2))/2 % mitad
 x2cu2 = (-x1cu-sqrt(20/216-5*(x1cu).^2))/2 %otra mitad
 plot(x1cu,x2cu1,'k')
 plot(x1cu,x2cu2,'k')

