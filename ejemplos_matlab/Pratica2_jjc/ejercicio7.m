%creamos unas variables simbolicas 
syms x1 x2 epsilon real
syms s


%definimos las ecuaciones del sistema
f(1,1) = x2
f(2,1) = -sin(x1) - epsilon*x2 

%Calculamos el Jacobiano
%J = jacobian(f,[x1 x2])
%obtenemos los puntos en que se anulan las ecuaciones de estado, ya que
%dichos puntos son precisamente los puntos deequilibrio
[x10,x20] = solve(f,[x1 x2])
X0 = [x10,x20]
%calculamos ahora resultados para todos los puntos de equilibrio
%encontrados


V = 1-cos(x1)+ x2^2/2

dotV = simplify(gradient(V)'*f)
for i =-4:0.5:4
    for j = -4:0.5:4
        [t,x] = ode45(@(t,x)ej8(t,x,3),[0 50],[i;j]);
        plot(x(:,1),x(:,2))
        hold on
    end
end
theta = 0:pi/100:2*pi
xc =pi*cos(theta)
yc =pi*sin(theta)
plot(xc,yc)