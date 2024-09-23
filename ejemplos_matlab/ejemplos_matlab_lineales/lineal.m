%calculo de sistemas lineales estables inestables asintoticamente estable
%etc
function lineal
xm =-1:0.2:1;
t = [0 1]

for i = 1:length(xm)
    for j = 1:length(xm)
        x0 = [xm(i);xm(j)];
        [t,x] = ode45(@real_menos,t,x0);
        plot(x0(1),x0(2),'.')
        hold on
        plot(x(:,1),x(:,2))
        plot(x(end,1),x(end,2),'x')
    end
    
end
end
function xdot = real_menos(t,x)
xdot = [-3 -2; 1 0]*x;
end

function xdot = cpl_mas(t,x)
xdot = [1 -3;4 2]*x;
end

function xdot = cpl_menos(t,x)
xdot = [-1 -3;4 -2]*x;
end
function xdot = real_mas(t,x)
xdot = [3 -2; 1 0]*x;
end

function xdot = silla(t,x)
xdot = [0 1; 1 0]*x;
end

function xdot = imaginario(t,x)
xdot = [-1 -3;4 1]*x;
end

function xdot = repetidosp(t,x)
xdot = [0 1;-1 2]*x;
end

function xdot = repetidosm(t,x)
xdot = [-2 1;-1 0]*x;
end

function xdot = uncero(t,x)
xdot = [-3 1;3 -1]*x;
end

function xdot = unceroi(t,x)
xdot = [1 1;1 1]*x;
end

function xdot = iguales(t,x)
xdot = [-1 0;0 -1]*x;
end

function xdot = ceros(t,x)
R =[cos(pi/4) -sin(pi/4); sin(pi/4) cos(pi/4)];
A = [0 0;1 0];
AR = R*A*R^-1;
xdot = AR*x;
end