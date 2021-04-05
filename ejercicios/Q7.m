% QUESTION 7

% Sistema y estimador
A = [1 1; -2 1];
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

% Comprobamos que el sistema es controlable
rank(ctrb(A,B))

% Diseñamos la ganancia L para el estimador (sección 8 en las notas)
L = place(A',C',[-5, -10])';

% Diseñamos la ganancia K para el controlador
K = place(A,B,[-1, -2]);

% Simulamos el sistema
for t = dt:dt:tf

u = -K*Xhat; % Controlador con los estados estimados
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