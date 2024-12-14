%creamos unas variables simbolicas 
syms x1 x2 real
syms s


%definimos las ecuaciones del sistema
f(1,1) = -x1 + x2
f(2,1) = -x1 + x2^2 

Calculamos el Jacobiano
J = jacobian(f,[x1 x2])
%obtenemos los puntos en que se anulan las ecuaciones de estado, ya que
%dichos puntos son precisamente los puntos deequilibrio
[x10,x20] = solve(f,[x1 x2])
X0 = [x10,x20]
%calculamos el jacobiano para esos puntos concretos 
%calculamos los autovalores
%Calculamos la ecuación caracteristica

for i = 1:size(X0,1)
    Je = subs(J,{x1,x2},X0(i,:))
    E = double(eig(Je))
    D = det(s*eye(length(X0(i,:))) - Je)
end

V= x1^2 + x2^2
grV = gradient(V)
dotV = simplify(grV'*f)
%el análisis de la derivada hay que hacerlo 'a mano' En este caso no es
%no es posible encontrar un entorno abierto centrado en el punto de
%equilibrio para el que se cumpla dotV<0 así que esta función candidata no
%nos vale...
%Podríamos buscar una funcion para el sistema linealizado, y luego analizar
%con ella la estabilidad del no lineal
%elegimos como Q la matriz identidad,
Je = subs(J,{x1,x2},X0(1,:))
P = lyap(double(Je)',eye(2))
V = simplify([x1 x2]*P*[x1;x2])
grV = gradient(V)
dotV = simplify(grV'*f)
% la derivada de lyapunov nos queda: -x1^2-x2^2(x1-3*x2+1)
 - x1^2 - x1 * x2^2 + 3 * x2^3 - x2^2.
% por tanto puedo asegurar estabilidad en una region x1^2, x2^2 siempre que
% se cumpla que los valores de x e y estén por encima de la recta x1-3*x2+1


for i =-1:0.2:1
    for j = -1:0.25:1
        [t,x] = ode45(@ej9,[0 2],[i;j]);
        plot(x(:,1),x(:,2))
        hold on
        plot(i,j,'or')
    end
end
x= -1:0.01:1;
%dibujo la recta que marca el límite y su perpendicular que pasa por el
%origen
plot(x,(x+1)/3,'r')
plot(x,-3*x,'r')
%busco el punto de corte de las dos rectas, (x1 = -1/10, x2=-3/10)
%mido la distancia de mi punto de corte al origen y trazo una
%circunferencia con dicho radio... en esa región puedo garantizar la
%estabilidad.. Pinto el circulo en cuention
x= -sqrt(1/10):sqrt(1/10)/100:sqrt(1/10);
plot(x,sqrt(1/10-x.^2),'k')
plot(x,-sqrt(1/10-x.^2),'k')





axis([-1 1 -1 1])

