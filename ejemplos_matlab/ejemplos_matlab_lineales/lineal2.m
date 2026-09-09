%calculo de sistemas lineales estables inestables asintoticamente estable
%etc

xm =-1:0.2:1;
t = [0 1];

real_menos = [-3 -2; 1 0];
cpl_mas = [-3 -2; 1 0];
cpl_menos = [-1 -3;4 -2];
real_mas = [3 -2; 1 0];
silla = [0 1; 1 0];
imaginario = [-1 -3;4 1];
repetidosp = [0 1;-1 2];
repetidosm = [-2 1;-1 0];
uncero = [-3 1;3 -1];
unceroi = [1 1;1 1];
iguales = [-1 0;0 -1];
R =[cos(pi/4) -sin(pi/4); sin(pi/4) cos(pi/4)];
A = [0 0;1 0];
ceros = R*A*R^-1;
circular = [0  -3.316624790355399; 3.316624790355399 0];


A = repetidosm;

% OJO: [l,v] = eig(A) NO hace lo que parece a simple vista.
% Con dos salidas, eig devuelve [V,D]: V son los AUTOVECTORES (columnas)
% y D es una matriz DIAGONAL con los autovalores, no un vector.
% Por tanto "l" son autovectores y "v" es una matriz diagonal, y l(1)/l(2)
% no son los autovalores. Para obtener los autovalores como vector:
[V,D] = eig(A);
lambda = diag(D);   % lambda(1), lambda(2) -> autovalores de A

% Construimos el string del titulo una sola vez, fuera del bucle,
% porque A (y por tanto sus autovalores) no cambia dentro del bucle.
titulo = sprintf('$\\lambda_1 = %s,\\ \\lambda_2 = %s$', ...
                  num2str(lambda(1)), num2str(lambda(2)));

figure
hold on
for i = 1:length(xm)
    for j = 1:length(xm)
        x0 = [xm(i);xm(j)];

        [t,x] = ode45(@(t,x)piltrafilla(t,x,A),t,x0);
        plot(x0(1),x0(2),'.')
        plot(x(:,1),x(:,2))
        plot(x(end,1),x(end,2),'x')
    end
end
title(titulo, 'Interpreter', 'latex')
xlabel('x_1')
ylabel('x_2')

function xdot = piltrafilla(t,x,A)
xdot = A*x;
end
