% QUESTION 6

% Sistema y estimador/observador
A = [0 1; -2 0];
B = [0;0];
C = [4 -7];
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
dt = 0.05; % Tiempo de paso
tf = 10; % Tiempo final

% Pintamos los estados iniciales
figure(4)
plot(x1, x2, 'ob')
hold on
plot(x1hat, x2hat, 'or')

% Comprobamos primero que el sistema es observable (controlabilidad del
% sistema dual)
rank(ctrb(A',C'))

% Diseñamos la ganancia L para el estimador (sección 8 en las notas)
L = place(A',C',[-5, -10])';

% Simulamos el sistema
for t = dt:dt:tf

u = 0;
Xdot = A*X + B*u;
Xhatdot = Ahat*Xhat + Bhat*u - L*(yhat-y);

% Integramos por Euler
X = X + Xdot*dt;
Xhat = Xhat + Xhatdot*dt;

y = C*X + D*u;
yhat = Chat*Xhat + Dhat*u;

% Pintamos la evolución de los estados y de las estimaciones
plot(X(1), X(2), 'ob')
plot(Xhat(1), Xhat(2), 'or')
pause(0.02)
end