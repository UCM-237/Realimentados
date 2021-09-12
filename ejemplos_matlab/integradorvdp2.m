% Solucion de la ecuacion de Va der Pol
%definimos la condición inicial
x0 = [3;-1];
m = 0.5;
C = 1;
L = 1;
[t,x] = ode45(@(t,x)vdp2(t,x,m,C,L),[0,50],x0);
subplot(2,1,1)
plot(t,x(:,1),'r')
hold on
plot(t,x(:,2))
title('Solucion de la ecuación de van der pol')
xlabel('tiempo')
legend('x_1','x_2')
subplot(2,1,2)
plot(x(:,1),x(:,2))
title('Trayectoria en el espacio de fases')
xlabel('x1')
ylabel('x2')
hold on
plot(x0(1),x0(2),'x')

% Mapa de fases.
% Creamos una región de interés en torno al origen que es el punto de
% equilibrio
x10 = [-2:1:2];
x20 = [-2:1:2];

% figura para pintar el diagrama de fases
figure
hold on
% podemos modificar los parametros del integrador. Aqui se ha ajustado
% La tolerancia relativa y el paso maximo de integracion para asegurar que
% las curvas que obtenemos son suaves. ademas para que de directamente el 
% diagrama de fases... agregar a odeset 'OutputFcn', @odephas2,
opts = odeset('Reltol',1e-9,'MaxStep',1e-1);
for i = 1:length(x10)
    for j = 1:length(x20)
        [t,x] = ode45(@(t,x)vdp2(t,x,m,C,L),[0,50],[x10(i);x20(j)],opts);
        % dibujamos los resultados
        plot(x10(i),x20(j),'^')
        plot(x(:,1),x(:,2))
    end
end
xlabel('x_1')
ylabel('x_2')