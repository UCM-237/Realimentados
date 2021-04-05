function dXdt = pendulo_estimador(t, X)

% Jacobianos del modelo no lineal del pendulo invertido, evaluados en
% theta = 0, dot_theta = 0, T = 0

m = 1; % kg
l = 1; % m
b = 0.1; % kg m² / s
g = 9.8; % m / s²

A = [0 1; g/l -b/(m*l*l)];
B = [0;1];
C = [1 0];
D = 0;

Ahat = A;
Bhat = B;
Chat = C;
Dhat = D;

K = [24.8, 7.9];     % Matriz de ganancias para la senal de control
L = [24.9; 157.31];  % Matriz de ganancias para el estimador

x = X(1:2);      % Esto es theta y dot_theta
xhat = X(3:4);   % Estas son las estimaciones de theta y dot_theta

u = -K*xhat; % Esta es la senal de control, el torque aplicado
y = C*x; % Esta es la salida del pendulo, la medida theta, es la g(x).
yhat = Chat*xhat + Dhat*u; % Esta es la salida estimada, la estimacion de theta

% Calculo de las derivadas temporales, el pendulo es NO lineal, pero el
% estimador si porque es para la linearizacion
theta = x(1);
dot_theta = x(2);
T = u;
dot_dot_theta = 1/(m*l*l) * (m*g*l*sin(theta) - b*dot_theta + T);

dot_x = [dot_theta; dot_dot_theta];
dot_xhat = Ahat*xhat + Bhat*u - L*(yhat - y);

dXdt = [dot_x ; dot_xhat]; % Las derivadas temporales de los estados del pendulo y del estimador

end

