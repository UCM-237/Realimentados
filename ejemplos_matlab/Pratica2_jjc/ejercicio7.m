%creamos unas variables simbolicas 
syms x1 x2 epsilon real
syms s


%definimos las ecuaciones del sistema
f(1,1) = x2
f(2,1) = -sin(x1) - epsilon*x2 

%Calculamos el Jacobiano
J = jacobian(f,[x1 x2])
%obtenemos los puntos en que se anulan las ecuaciones de estado, ya que
%dichos puntos son precisamente los puntos deequilibrio
[x10,x20] = solve(f,[x1 x2])
X0 = [x10,x20]
%calculamos ahora resultados para todos los puntos de equilibrio
%encontrados (solo hay uno así que abrevio)
Je = subs(J,{x1,x2},X0)
E = simplify(eig(Je))
%estable

%funcion de liapunov
V = 1-cos(x1)+ x2^2/2

dotV = simplify(gradient(V)'*f)
for i =-4:0.5:4
    for j = -4:0.5:4
        [t,x] = ode45(@(t,x)ej7(t,x,0.2),[0 50],[i;j]);
        plot(x(:,1),x(:,2))
        hold on
    end
end
%dibujamos el circulo limite que impone la propia función de Lyapunov
%ya que fuera de ese límite no se cumple la condición V>0 en x2 =0.
%si usamos lasalle nos valen todos los puntos de equilibrio del oscilador
theta = 0:pi/100:2*pi;
xc =2*cos(theta);
yc =2*sin(theta);
plot(xc,yc,'k',LineWidth=2)