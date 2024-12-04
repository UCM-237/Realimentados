%close all
clear all

x01 = -10:1:10;
x02 = x01;
param = odeset('AbsTol', 1e-9)
for i = 1:length(x01)
    for j = 1:length(x02)
        tf = 100;
        [t,x] = ode45(@(t,x)dote7(t,x),[0,tf],[x01(i);x02(j)]);
        
        plot(x(:,1),x(:,2))
        hold on
        plot(x01(i),x02(j),'^')
       
    end
end
%limito el area de dibujo ya que los puntos iniciales inestables divergen
%muy lejos
axis([-1 1 -1 1])
%pinto la frontera,
x = -10:0.01:10
y = 1/6 - x
plot(x,y,'k')
%dibujo el circulo obtenido en ejercicio ej7
x1 = linspace(-sqrt(2)/12,sqrt(2)/6,200);
x2p =sqrt(1/72-x1.^2);
x2m =-sqrt(1/72-x1.^2);
plot(x1,x2p)
plot(x1,x2m)
%y tambien la elipse curva de nivel de la función de lyapunov 
x1cu = linspace(-sqrt(4/216),sqrt(4/216),200);
 x2cu1 = (-x1cu+sqrt(20/216-5*(x1cu).^2))/2 % mitad
 x2cu2 = (-x1cu-sqrt(20/216-5*(x1cu).^2))/2 %otra mitad
 plot(x1cu,x2cu1,'k')
 plot(x1cu,x2cu2,'k')
axis('square')