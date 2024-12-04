%Dado el sistema
%dotx1 = x2
%dotx2 = -x1 + x2(x1^2-1)
%creamos unas variables simbolicas 
syms x1 x2 real
syms s

%definimos las ecuaciones del sistema
f(1,1) = x2
f(2,1) = -x1 + x2*(x1^2-1)

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
%podemos probar con una función tentativa liapunov sencillita,
V = x1^2 +x2^2
vdot = simplify(gradient(V)'*f)
%podemos buscar una tentativa para el lineal y aplicarsela...
jen = double(Je)
P = lyap(jen',eye(2))
V = [x1 x2]*P*[x1;x2]
vdot = expand(gradient(V)'*f)
%en este caso sale complicado
%simulamos y dibujamos el circulo unidad que obtendríamos de la primera
%función de Lyapunov,
for i =-1.5:0.2:1.5%5
     for j = -1.5:0.2:1.5 %5
        [t,x] = ode45(@ej5,[0 1],[i;j]);
        plot(i,j,'xr')
        hold on
        plot(x(:,1),x(:,2))
        
     end
end
theta =0:pi/100:2*pi
plot(cos(theta),sin(theta),'b')
axis([-2,2,-2,2])
figure()
% Sacamos el basin por simulación integrando hacia atras en el tiempo
 for i =-4:0.5:4%5
     for j = -4:0.5:4 %5
        [t,x] = ode45(@ej5,[0 -10],[i;j]);
        plot(i,j,'xr')
        hold on
        plot(x(:,1),x(:,2))
        
     end
end
