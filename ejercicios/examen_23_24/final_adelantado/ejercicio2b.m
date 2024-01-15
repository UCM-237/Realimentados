
close all
clear all
%definimos el sistema en simbolico
syms x1 x2 real
f(1,1) = -x1*(x1^2 + x2^2 -1) +x2
f(2,1) = -x1 - x2*(x1^2+x2^2-1)

J = jacobian(f,[x1 x2])

[x10,x20] = solve(f,[x1 x2])

Je = subs(J,{x1,x2},[x10 x20])

E = double(eig(Je))
%Usa la V del ejercicio anterior
V = x1^2/2+x2^2/2
grv = gradient(V)
dotv= grv'*f
dotv = simplify(dotv)

%  %calculamos la soluci�n con ode45
% % El punto de equilibrio es el punto (0,0)
% %para puntos pr�ximos al de equilibrio
x1_0 = -1:0.3:1;
x2_0 = -1:0.3:1;
% %dentro
for i = 1:length(x1_0)
     for j = 1:length(x2_0)
         if x1_0(i)^2+x2_0(j)^2>=1
             tf= 0.3;
         else
             tf =10;
         end
         [t,x] = ode45(@(t,x)eje2(t,x),[0,tf],[x1_0(i);x2_0(j)]);
         plot(x1_0(i),x2_0(j),'o')
         hold on
         plot(x(:,1),x(:,2))
         
         
     end
 end
xc = cos(0:pi/100:2*pi);
yc = sin(0:pi/100:2*pi);
plot(xc,yc,'r')
axis('equal')
% 
% end
% 
function dotx = eje2(t,x) 
dotx(1,1) = -x(1,1)*(x(1,1)^2 + x(2,1)^2-1)+x(2,1);
dotx(2,1) = -x(1,1)  -x(2,1)*(x(1,1)^2+x(2,1)^2-1);
end

