% Modelo
A = [0 1; 0 -5];
B = [0; 1];
D = 0;

% Sistema real
At = A + 0.1*rand(2,2);
Bt = B + 0.1*rand(2,1);

% Mediciones
C1 = eye(2);
C2 = [1 0];

% Diseño controlador con las matrices del modelo
Aamp = [A [0;0]; C2 0];
Bamp = [B; 0];

y2d = 23; % Valor deseado para la posición

lambda_des = [-1, -2, -3]; % valores propios deseados para (6.73)
Kamp = acker(Aamp,Bamp,lambda_des);
K = Kamp(1:2); % Para los estados
KI = Kamp(3); % Para el error integral

% Simulacion
tf = 100;
deltaT = 0.01;
t = [0:0.01:100];

e = 13; % valor inicial para la integral
x = [125;-3];


log_x = zeros(length(t), 2);
log_u = zeros(length(t), 1);

for i = 1:length(t)
    
   u = -K*(C1*x) -KI*e;
   e_dot = C2*x - y2d;
   x_dot = At*x + Bt*u; % simulamos el sistema real
   
   
   log_x(i,:) = x;
   log_u(i,:) = u;
   x = x + x_dot*deltaT;
   e = e + e_dot*deltaT;
   
   
end

figure(1)
plot(t, log_x(:,1), 'r');
hold on;
plot(t, log_x(:,2), 'g');

figure(2)
plot(t, log_u(:), 'k');