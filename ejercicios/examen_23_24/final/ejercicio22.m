function ejercicio2
close all
clear all
%definimos el sistema en simbolico
syms x1 x2 real
f(1,1) = 1/x2 -x1^2
f(2,1) = x1/x2 -1

J = jacobian(f,[x1 x2])

[x10,x20] = solve(f,[x1 x2])

Je = subs(J,{x1,x2},[1 1])

E = double(eig(Je))

V = (x1-1)^2+(x2-1)^2
grv = gradient(V)
dotv= grv'*f
dotv = expand(dotv)

%vamos a pintarlo en 3d
xr1 = 0.1:0.05:1.5;
xr2 = 0.1:0.05:1.5;
[x1m x2m] = meshgrid(xr1,xr2);
zm = -2*x1m.^3 + 2*x1m.^2 +2*x1m- 2*x2m -2./x2m + 2;
mesh(x1m,x2m,zm)
xlabel('x1')
ylabel('x2')
zlabel('dotv')
hold on
%y le pintamos un plano cero para que se vea que no hay trampa ni carton
mesh(x1m,x2m,zeros(size(x1m)))
figure
 %calculamos la soluci�n con ode45
% El punto de equilibrio es el punto (1,1)
%para puntos pr�ximos al de equilibrio
x1_0 = 0:0.4:2;
x2_0 = 0:0.3:2;
%dentro
for i = 1:length(x1_0)
    for j = 1:length(x2_0)
        [i j];
       
        [t,x] = ode45(@(t,x) eje2(t,x),[0,2],[x1_0(i);x2_0(j)]);
        plot(x1_0(i),x2_0(j),'o')
        hold on
        plot(x(:,1),x(:,2))     
    end
end


end

function dotx = eje2(t,x)
dotx(1,1) = 1/x(2) - x(1)^2;
dotx(2,1) = x(1)/x(2) - 1;
end


