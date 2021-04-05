% QUESTION 5

% Sistema y estimador/observador
A = [0 1; 0 0];
B = [0;1];
C = [1 0];
D = 0;

Ahat = A;
Bhat = B;
Chat = C;
Dhat = D;

% Condiciones iniciales
x1 = 34;
x2 = -4;

x1hat = 0;
x2hat = 0;

X = [x1;x2];
y = C*X;

Xhat = [x1hat;x2hat];
yhat = Chat*Xhat;

% Tiempos para la simulación
dt = 0.01; % Tiempo de paso
tf = 3; % Tiempo final

% Pintamos los estados iniciales
figure(3)
plot(0, x1, 'ob')
hold on
plot(0, x2, 'or')
plot(0, x1hat, 'xb')
plot(0, x2hat, 'xr')

% Comprobamos primero que el sistema es observable (controlabilidad del
% sistema dual)
rank(ctrb(A',C'))

% Diseñamos la ganancia L para el estimador (sección 8 en las notas)
L = place(A',C',[-5, -10])';

% Simulamos el sistema
for t = dt:dt:tf

u = 15*cos(5*t);
Xdot = A*X + B*u;
Xhatdot = Ahat*Xhat + Bhat*u - L*(yhat-y);

% Integramos por Euler
X = X + Xdot*dt;
Xhat = Xhat + Xhatdot*dt;

y = C*X + D*u;
yhat = Chat*Xhat + Dhat*u;

% Pintamos la evolución de los estados y de las estimaciones
plot(t, X(1), 'ob')
plot(t, X(2), 'or')
plot(t, Xhat(1), 'xb')
plot(t, Xhat(2), 'xr')
pause(0.02)
end