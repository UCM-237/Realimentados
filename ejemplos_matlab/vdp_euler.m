%solucion de la ecuacion de van der pool emplendo el metodo de euler
%Integracion de Euler
%md2x+2c(x^2-1)dx+kx =0
%lo represntamos en ecuaciones de estado
%dx1 = x2
%dx2 = (1/m)[-c(x1^2-1)x2-k*x1
%lo discretizamos
%x1(t+dt) = xi(t)+x2(t)*dt
%x2(t+dt) = x2(t)+(1/m)*[-c(x1(t)^2-1)x2(t)-kx1(t)*dt
%definimos los parametros de la ecuación
m = 1; c = 0.5; k = 1;
%definimos las condiciones iniciales
x0 = [-1,2];
%podemos definir varias condiciones iniciales y repetir el calculo
%definimos el paso de integracion
dt = 0.1;
%representamos la condición inicial
plot(x0(1,1),x0(1,2),'r*')
hold on

% igualamos el estado actual al estado inicial
x = x0;
%Construimos un bucle para calcular por euler los dos sucesivos
for t = 0:dt:20
    u = x(2);
    v = (1/m)*(-k*x(1) + 2*c*(1-x(1)^2)*x(2));
    xn(1) = x(1)+dt*u;
    xn(2) = x(2)+dt*v;
    plot([x(1),xn(1)],[x(2),xn(2)])
    x =xn
end
 
%calculo y representación del campo vectorial asociado al modelo
x = [-3:.5:3];
y = x;
[X,Y] = meshgrid(x,y)
U = Y
V = (1/m)*(-k*X+2*c*(1-x.^2).*Y)
quiver(x,y,U,V)
%las flechas muestran la 'velocidad' vectores de flujo